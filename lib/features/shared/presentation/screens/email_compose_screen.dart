import 'package:crm_app/config/theme/app_theme.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/contacts/presentation/providers/contact_provider.dart';
import 'package:crm_app/features/shared/domain/entities/email_recipient.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_request.dart';
import 'package:crm_app/features/shared/presentation/providers/email_send_provider.dart';
import 'package:crm_app/features/shared/widgets/email_quill_editor.dart';
import 'package:crm_app/features/shared/widgets/email_compose_fields_chips.dart';
import 'package:crm_app/features/shared/widgets/email_recipients_chips.dart';
import 'package:crm_app/features/shared/widgets/email_compose_header.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:crm_app/features/shared/infrastructure/services/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmailComposeScreen extends ConsumerStatefulWidget {
  final String contactId;
  const EmailComposeScreen({super.key, required this.contactId});

  @override
  ConsumerState<EmailComposeScreen> createState() => _EmailComposeScreenState();
}

class _EmailComposeScreenState extends ConsumerState<EmailComposeScreen> {
  final List<EmailRecipientData> _toRecipients = [];
  final List<EmailRecipientData> _ccRecipients = [];
  final List<EmailRecipientData> _bccRecipients = [];
  
  final subjectController = TextEditingController();
  String _emailBodyHtml = '';
  List<PlatformFile> _attachedFiles = [];
  
  bool _contactAdded = false;

  // GlobalKeys para acceder a los estados de los campos de recipients
  final GlobalKey<EmailRecipientsChipsState> _toKey = GlobalKey<EmailRecipientsChipsState>();
  final GlobalKey<EmailRecipientsChipsState> _ccKey = GlobalKey<EmailRecipientsChipsState>();
  final GlobalKey<EmailRecipientsChipsState> _bccKey = GlobalKey<EmailRecipientsChipsState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactProvider(widget.contactId).notifier).loadContact(widget.contactId);
    });
  }

  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(contactProvider(widget.contactId));
    final contact = contactState.contact;
    final email = contact?.contactoEmail ?? '';
    
    // Agregar contacto principal automáticamente (solo una vez)
    // name y address deben ser iguales (el email)
    if (email.trim().isNotEmpty && !_contactAdded) {
      _toRecipients.add(EmailRecipientData(
        name: email.trim(),
        email: email.trim(),
        isRemovable: false, // El contacto principal NO se puede eliminar
      ));
      _contactAdded = true;
    }
    
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enviar correo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header fijo arriba (no hace scroll)
          EmailComposeHeader(
            onLogout: () => Navigator.pop(context),
            attachedFiles: _attachedFiles,
            onAddFiles: (files) => setState(() => _attachedFiles = files),
            onSend: (List<PlatformFile> selectedFiles) async {
              await _sendEmail(selectedFiles, authState, contact);
            },
          ),
          
          // Contenido scrollable cuando aparece el teclado
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Lista de archivos adjuntos (arriba de PARA)
                  EmailAttachedFilesList(
                    attachedFiles: _attachedFiles,
                    onRemoveFile: (files) => setState(() => _attachedFiles = files),
                  ),
                  
                  EmailComposeFieldsChips(
                    toRecipients: _toRecipients,
                    ccRecipients: _ccRecipients,
                    bccRecipients: _bccRecipients,
                    onAddTo: (recipient) => setState(() => _toRecipients.add(recipient)),
                    onRemoveTo: (index) {
                      if (_toRecipients[index].isRemovable) {
                        setState(() => _toRecipients.removeAt(index));
                      }
                    },
                    onAddCc: (recipient) => setState(() => _ccRecipients.add(recipient)),
                    onRemoveCc: (index) => setState(() => _ccRecipients.removeAt(index)),
                    onAddBcc: (recipient) => setState(() => _bccRecipients.add(recipient)),
                    onRemoveBcc: (index) => setState(() => _bccRecipients.removeAt(index)),
                    subjectController: subjectController,
                    toKey: _toKey,
                    ccKey: _ccKey,
                    bccKey: _bccKey,
                  ),
                  
                  // Editor con altura fija más razonable
                  SizedBox(
                    height: 400,
                    child: EmailQuillEditor(
                      onContentChanged: (html) {
                        _emailBodyHtml = html;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail(List<PlatformFile> selectedFiles, authState, contact) async {
    final user = authState.user;
    final asunto = subjectController.text.trim();
    final comentario = _emailBodyHtml.trim();

    // VALIDACIONES EN ORDEN (SIN MOSTRAR LOADING AÚN): CORREOS → ASUNTO → CUERPO
    
    // ============================================
    // PRIORIDAD 1: Datos básicos del sistema
    // ============================================
    if (user == null || contact == null) {
      if (!mounted) return;
      NotificationService().showError(
        context: context,
        title: 'Error de información',
        message: 'No se pudo cargar la información del usuario o contacto.',
      );
      return;
    }

    if (contact.ruc.trim().isEmpty) {
      if (!mounted) return;
      NotificationService().showError(
        context: context,
        title: 'Datos incompletos',
        message: 'El contacto no tiene RUC asociado.',
      );
      return;
    }

    // ============================================
    // PRIORIDAD 2: Validar CORREOS (PARA + CC + BCC juntos)
    // ============================================
    
    // 2.1: PARA debe tener al menos un destinatario
    if (_toRecipients.isEmpty) {
      if (!mounted) return;
      NotificationService().showWarning(
        context: context,
        title: 'Falta destinatario',
        message: 'Debe agregar al menos un destinatario en PARA.',
      );
      return;
    }

    // 2.2: Validar texto pendiente en TODOS los campos (PARA + CC + BCC)
    final List<String> pendingEmails = [];
    
    final pendingToEmail = _toKey.currentState?.getPendingEmail();
    if (pendingToEmail != null) {
      pendingEmails.add('PARA: $pendingToEmail');
    }

    final pendingCcEmail = _ccKey.currentState?.getPendingEmail();
    if (pendingCcEmail != null) {
      pendingEmails.add('CC: $pendingCcEmail');
    }

    final pendingBccEmail = _bccKey.currentState?.getPendingEmail();
    if (pendingBccEmail != null) {
      pendingEmails.add('BCC: $pendingBccEmail');
    }

    if (pendingEmails.isNotEmpty) {
      if (!mounted) return;
      final message = pendingEmails.length == 1
          ? 'Tienes un email sin agregar: ${pendingEmails[0]}\nPresiona Enter para agregarlo o bórralo.'
          : 'Tienes ${pendingEmails.length} emails sin agregar:\n${pendingEmails.join('\n')}\nPresiona Enter para agregarlos o bórralos.';
      
      NotificationService().showWarning(
        context: context,
        title: 'Emails pendientes',
        message: message,
      );
      return;
    }

    // 2.3: Validar formato de TODOS los emails agregados (PARA + CC + BCC en conjunto)
    final List<String> invalidEmails = [];
    
    for (final recipient in _toRecipients) {
      if (!_isValidEmail(recipient.email)) {
        invalidEmails.add(recipient.email);
      }
    }

    for (final recipient in _ccRecipients) {
      if (!_isValidEmail(recipient.email)) {
        invalidEmails.add(recipient.email);
      }
    }

    for (final recipient in _bccRecipients) {
      if (!_isValidEmail(recipient.email)) {
        invalidEmails.add(recipient.email);
      }
    }

    // Si hay emails inválidos, mostrar error consolidado (TODOS JUNTOS)
    if (invalidEmails.isNotEmpty) {
      if (!mounted) return;
      final message = invalidEmails.length == 1
          ? 'La dirección de correo electrónico ${invalidEmails[0]} no es válida.'
          : '${invalidEmails.length} correos electrónicos no son válidos.';
      
      NotificationService().showError(
        context: context,
        title: 'Correo inválido',
        message: message,
        duration: 5000,
      );
      return;
    }

    // ============================================
    // PRIORIDAD 3: Validar ASUNTO
    // ============================================
    if (asunto.isEmpty) {
      if (!mounted) return;
      NotificationService().showWarning(
        context: context,
        title: 'Falta asunto',
        message: 'Debe completar el asunto del correo.',
      );
      return;
    }

    // ============================================
    // PRIORIDAD 4: Validar CUERPO/MENSAJE
    // ============================================
    if (comentario.isEmpty) {
      if (!mounted) return;
      NotificationService().showWarning(
        context: context,
        title: 'Falta cuerpo del mensaje',
        message: 'Debe completar el cuerpo del correo.',
      );
      return;
    }

    // Mostrar loading dialog INMEDIATAMENTE (antes de preparar archivos)
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Enviando correo...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );

    // OPTIMIZACIÓN: Ejecutar TODAS las operaciones pre-envío EN PARALELO
    // En lugar de: archivos -> recipients -> oportunidadId (secuencial)
    // Ahora: archivos + oportunidadId + returnRoute al mismo tiempo
    final storage = KeyValueStorageServiceImpl();
    
    print('========== PREPARANDO ENVÍO DE CORREO ==========');
    print('Archivos seleccionados: ${selectedFiles.length}');
    for (var i = 0; i < selectedFiles.length; i++) {
      print('  Archivo $i:');
      print('    - Nombre: ${selectedFiles[i].name}');
      print('    - Path: ${selectedFiles[i].path}');
      print('    - Size: ${selectedFiles[i].size} bytes');
      print('    - Extension: ${selectedFiles[i].extension}');
    }
    
    final results = await Future.wait([
      // 1. Preparar archivos en paralelo
      Future.wait(
        selectedFiles
            .where((f) => f.path != null)
            .map((file) => MultipartFile.fromFile(file.path!, filename: file.name)),
      ),
      // 2. Obtener oportunidadId
      storage.getValue<String>('email_opportunity_id'),
      // 3. Obtener returnRoute (necesario después)
      storage.getValue<String>('email_return_route'),
    ]);

    final List<MultipartFile> files = results[0] as List<MultipartFile>;
    final String? savedOpportunityId = results[1] as String?;
    final String? returnRoute = results[2] as String?;
    
    print('========== ARCHIVOS CONVERTIDOS A MULTIPART ==========');
    print('MultipartFiles creados: ${files.length}');
    for (var i = 0; i < files.length; i++) {
      print('  MultipartFile $i:');
      print('    - Filename: ${files[i].filename}');
      print('    - Length: ${files[i].length} bytes');
    }
    print('==================================================');
    
    // Recipients (instantáneo, no requiere await)
    final recipients = _buildRecipients(contact.id);
    
    String oportunidadId = '0';
    if (savedOpportunityId != null && savedOpportunityId.isNotEmpty) {
      oportunidadId = savedOpportunityId;
      // Eliminar en background sin esperar
      storage.removeKey('email_opportunity_id');
    }

    // Enviar correo y esperar respuesta del backend (este es el único await crítico)
    bool success = false;
    String apiMessage = 'No se pudo enviar el correo.';
    
    try {
      success = await ref.read(emailSendProvider.notifier).sendEmail(
        SendEmailRequest(
          usuarioResponsableId: user.code,
          ruc: contact.ruc.trim(),
          contactoId: contact.id,
          oportunidadId: oportunidadId,
          asunto: asunto,
          comentario: comentario,
          userEmail: user.email,
          emailFrom: user.email,
          recipients: recipients,
          files: files,
        ),
      );

      // Obtener mensaje del backend
      final sendState = ref.read(emailSendProvider);
      apiMessage = sendState.message ?? 'No se pudo enviar el correo.';
    } catch (e) {
      success = false;
      apiMessage = 'Error al enviar el correo. Por favor intenta nuevamente.';
    }

    // Cerrar loading dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    if (!mounted) return;
    
    // Mostrar notificación
    if (success) {
      NotificationService().showSuccess(
        context: context,
        title: 'Correo enviado exitosamente',
        message: apiMessage,
        duration: 5000,
      );
      setState(() {
        _attachedFiles = [];
      });
    } else {
      NotificationService().showError(
        context: context,
        title: 'Error al enviar correo',
        message: apiMessage,
        duration: 6000,
      );
    }

    if (!success) return;

    // OPTIMIZACIÓN: Operaciones post-envío en background (no bloquean navegación)
    storage.setKeyValue<int>('email_sent_tick', DateTime.now().millisecondsSinceEpoch);
    
    if (!mounted) return;
    if (returnRoute != null && returnRoute.isNotEmpty) {
      storage.removeKey('email_return_route'); // background
      context.go(returnRoute);
    } else {
      context.go('/contact_detail/${widget.contactId}');
    }
  }

  List<EmailRecipient> _buildRecipients(String contactId) {
    final recipients = <EmailRecipient>[];
    
    // TO
    for (final recipient in _toRecipients) {
      recipients.add(EmailRecipient(
        contactId: contactId,
        name: recipient.name,
        email: recipient.email,
        type: EmailRecipientType.to,
      ));
    }
    
    // CC
    for (final recipient in _ccRecipients) {
      recipients.add(EmailRecipient(
        contactId: contactId,
        name: recipient.name,
        email: recipient.email,
        type: EmailRecipientType.cc,
      ));
    }
    
    // BCC
    for (final recipient in _bccRecipients) {
      recipients.add(EmailRecipient(
        contactId: contactId,
        name: recipient.name,
        email: recipient.email,
        type: EmailRecipientType.cco,
      ));
    }
    
    return recipients;
  }

  bool _isValidEmail(String email) {
    // Regex completo para validar formato de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    
    // Verificar formato básico
    if (!emailRegex.hasMatch(email)) {
      return false;
    }
    
    // Validaciones adicionales
    final parts = email.split('@');
    if (parts.length != 2) return false;
    
    final localPart = parts[0];
    final domainPart = parts[1];
    
    // La parte local no puede estar vacía ni empezar/terminar con punto
    if (localPart.isEmpty || localPart.startsWith('.') || localPart.endsWith('.')) {
      return false;
    }
    
    // La parte del dominio debe tener al menos un punto
    if (!domainPart.contains('.')) {
      return false;
    }
    
    // El dominio no puede empezar o terminar con punto o guión
    if (domainPart.startsWith('.') || domainPart.endsWith('.') ||
        domainPart.startsWith('-') || domainPart.endsWith('-')) {
      return false;
    }
    
    return true;
  }
}

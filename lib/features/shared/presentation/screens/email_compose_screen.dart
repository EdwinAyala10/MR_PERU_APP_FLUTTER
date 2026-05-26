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
  
  bool _contactAdded = false;

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
            onSend: (List<PlatformFile> selectedFiles) async {
              await _sendEmail(selectedFiles, authState, contact);
            },
          ),
          
          // Contenido scrollable cuando aparece el teclado
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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

    // Validaciones
    if (user == null || contact == null) {
      if (!mounted) return;
      NotificationService().showError(
        context: context,
        title: 'Error de información',
        message: 'No se pudo cargar la información del usuario o contacto.',
      );
      return;
    }

    if (_toRecipients.isEmpty) {
      if (!mounted) return;
      NotificationService().showWarning(
        context: context,
        title: 'Falta destinatario',
        message: 'Debe agregar al menos un destinatario para enviar el correo.',
      );
      return;
    }

    if (asunto.isEmpty || comentario.isEmpty) {
      if (!mounted) return;
      NotificationService().showWarning(
        context: context,
        title: 'Campos obligatorios',
        message: 'El asunto y el mensaje son obligatorios.',
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

    // Preparar archivos adjuntos
    final List<MultipartFile> files = [];
    for (final file in selectedFiles) {
      final path = file.path;
      if (path == null) continue;
      files.add(await MultipartFile.fromFile(path, filename: file.name));
    }

    // Construir recipients
    final recipients = _buildRecipients(contact.id);

    // Enviar
    final success = await ref.read(emailSendProvider.notifier).sendEmail(
      SendEmailRequest(
        usuarioResponsableId: user.code,
        ruc: contact.ruc.trim(),
        contactoId: contact.id,
        asunto: asunto,
        comentario: comentario,
        userEmail: user.email,
        emailFrom: user.email,
        recipients: recipients,
        files: files,
      ),
    );

    // Mostrar resultado
    final sendState = ref.read(emailSendProvider);
    final apiMessage = sendState.message ?? 'No se pudo enviar el correo.';

    if (!mounted) return;
    
    // Mostrar notificación con mensaje de éxito o error
    if (success) {
      // Extraer Activity ID si está disponible
      String activityInfo = '';
      if (sendState.data != null && sendState.data is Map) {
        final dataMap = sendState.data as Map;
        if (dataMap['Actividad'] != null && dataMap['Actividad'] is Map) {
          final actividad = dataMap['Actividad'] as Map;
          final activityId = actividad['ACTI_ID_ACTIVIDAD'];
          if (activityId != null) {
            activityInfo = '\nActivity ID: $activityId';
          }
        }
      }
      
      NotificationService().showSuccess(
        context: context,
        title: 'Correo enviado exitosamente',
        message: '$apiMessage$activityInfo',
        duration: 5000,
      );
    } else {
      NotificationService().showError(
        context: context,
        title: 'Error al enviar correo',
        message: apiMessage,
        duration: 6000,
      );
    }

    if (!success) return;

    // Navegar de vuelta
    final tick = DateTime.now().millisecondsSinceEpoch;
    await KeyValueStorageServiceImpl().setKeyValue<int>('email_sent_tick', tick);
    final returnRoute = await KeyValueStorageServiceImpl().getValue<String>('email_return_route');
    if (!mounted) return;
    if (returnRoute != null && returnRoute.isNotEmpty) {
      await KeyValueStorageServiceImpl().removeKey('email_return_route');
      if (!mounted) return;
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
}

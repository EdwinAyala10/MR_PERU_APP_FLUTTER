import 'package:crm_app/config/theme/app_theme.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/contacts/presentation/providers/contact_provider.dart';
import 'package:crm_app/features/shared/domain/entities/email_recipient.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_request.dart';
import 'package:crm_app/features/shared/presentation/providers/email_send_provider.dart';
import 'package:crm_app/features/shared/widgets/email_compose_body.dart';
import 'package:crm_app/features/shared/widgets/email_compose_fields.dart';
import 'package:crm_app/features/shared/widgets/email_feedback_snackbar.dart';
import 'package:crm_app/features/shared/widgets/email_compose_header.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
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
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

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
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(contactProvider(widget.contactId));
    final email = contactState.contact?.contactoEmail ?? '';
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enviar correo',
          style: TextStyle(
            color: secondaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          EmailComposeHeader(
            onLogout: () => Navigator.pop(context),
            onSend: (List<PlatformFile> selectedFiles) async {
              final user = authState.user;
              final contact = contactState.contact;
              final asunto = subjectController.text.trim();
              final comentario = bodyController.text.trim();

              if (user == null || contact == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo cargar la información del usuario o contacto.')),
                );
                return;
              }

              if ((contact.contactoEmail ?? '').trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El contacto no tiene correo electrónico.')),
                );
                return;
              }

              if (asunto.isEmpty || comentario.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Asunto y mensaje son obligatorios.')),
                );
                return;
              }

              if (contact.ruc.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El contacto no tiene RUC asociado.')),
                );
                return;
              }

              final List<MultipartFile> files = [];
              for (final file in selectedFiles) {
                final path = file.path;
                if (path == null) continue;
                files.add(await MultipartFile.fromFile(path, filename: file.name));
              }

              final success = await ref.read(emailSendProvider.notifier).sendEmail(
                    SendEmailRequest(
                      usuarioResponsableId: user.code,
                      ruc: contact.ruc.trim(),
                      contactoId: contact.id,
                      asunto: asunto,
                      comentario: comentario,
                      userEmail: user.email,
                      emailFrom: user.email,
                      recipients: [
                        EmailRecipient(
                          contactId: contact.id,
                          email: contact.contactoEmail!.trim(),
                          type: EmailRecipientType.to,
                        ),
                      ],
                      files: files,
                    ),
                  );

              if (!success) {
                if (!context.mounted) return;
                final errorMessage = ref.read(emailSendProvider).message ?? 'No se pudo enviar el correo.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
                return;
              }

              final tick = DateTime.now().millisecondsSinceEpoch;
              await KeyValueStorageServiceImpl().setKeyValue<int>('email_sent_tick', tick);
              if (!context.mounted) return;
              EmailFeedbackSnackbar.showEmailSent(context);
              final returnRoute = await KeyValueStorageServiceImpl().getValue<String>('email_return_route');
              if (!context.mounted) return;
              if (returnRoute != null && returnRoute.isNotEmpty) {
                await KeyValueStorageServiceImpl().removeKey('email_return_route');
                if (!context.mounted) return;
                context.go(returnRoute);
              } else {
                context.go('/contact_detail/${widget.contactId}');
              }
            },
          ),
          EmailComposeFields(toEmail: email, subjectController: subjectController),
          Expanded(child: EmailComposeBody(controller: bodyController)),
        ],
      ),
    );
  }
}

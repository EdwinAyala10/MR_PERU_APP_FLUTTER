import 'package:crm_app/config/theme/app_theme.dart';
import 'package:crm_app/features/contacts/presentation/providers/contact_provider.dart';
import 'package:crm_app/features/shared/widgets/email_compose_body.dart';
import 'package:crm_app/features/shared/widgets/email_compose_fields.dart';
import 'package:crm_app/features/shared/widgets/email_feedback_snackbar.dart';
import 'package:crm_app/features/shared/widgets/email_compose_header.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar correo')),
      body: Column(
        children: [
          EmailComposeHeader(
            onLogout: () => Navigator.pop(context),
            onSend: () async {
              final tick = DateTime.now().millisecondsSinceEpoch;
              await KeyValueStorageServiceImpl().setKeyValue<int>('email_sent_tick', tick);
              if (!context.mounted) return;
              EmailFeedbackSnackbar.showEmailSent(context);
              final returnRoute = await KeyValueStorageServiceImpl().getValue<String>('email_return_route');
              if (!context.mounted) return;
              if (returnRoute != null && returnRoute.isNotEmpty) {
                await KeyValueStorageServiceImpl().removeKey('email_return_route');
                context.go(returnRoute);
              } else {
                context.go('/contact_detail/${widget.contactId}');
              }
            },
          ),
          EmailComposeFields(toEmail: email, subjectController: subjectController),
          const Divider(height: 1),
          Expanded(child: EmailComposeBody(controller: bodyController)),
        ],
      ),
    );
  }
}

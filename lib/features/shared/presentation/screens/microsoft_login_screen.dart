import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:crm_app/config/theme/app_theme.dart';

class MicrosoftLoginScreen extends StatelessWidget {
  final String email;

  const MicrosoftLoginScreen({super.key, required this.email});

  void _continueWithMicrosoft(BuildContext context) async {
    await KeyValueStorageServiceImpl().setKeyValue('microsoft_synced', true);
    await KeyValueStorageServiceImpl().setKeyValue('show_sync_message', true);
    final returnRoute = await KeyValueStorageServiceImpl().getValue<String>('email_return_route');
    final contactId = await KeyValueStorageServiceImpl().getValue<String>('current_contact_id');
    
    if (!context.mounted) return;
    
    if (returnRoute != null && returnRoute.isNotEmpty) {
      await KeyValueStorageServiceImpl().removeKey('email_return_route');
      context.push(returnRoute);
    } else if (contactId != null && contactId.isNotEmpty) {
      context.push('/contact_detail/$contactId');
    } else {
      context.push('/contacts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: secondaryColor),
              ),
              const SizedBox(height: 14),
              const Text('Welcome', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: secondaryColor)),
              const SizedBox(height: 10),
              Text('Log in to your $email', style: const TextStyle(fontSize: 18, color: secondaryColor)),
              const SizedBox(height: 10),
              const Text(
                'Al continuar, Microsoft abrira el inicio de sesion para autorizar la sincronizacion.',
                style: TextStyle(fontSize: 14, color: secondaryColor, height: 1.35),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueWithMicrosoft(context),
                  child: const Text('Continue with Microsoft'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

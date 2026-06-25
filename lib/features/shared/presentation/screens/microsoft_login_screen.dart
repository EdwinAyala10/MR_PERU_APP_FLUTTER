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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.25),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: primaryColor,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: secondaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Iniciar sesión en $email',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Al continuar, Microsoft abrirá el inicio de sesión para autorizar la sincronización.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueWithMicrosoft(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar con Microsoft',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

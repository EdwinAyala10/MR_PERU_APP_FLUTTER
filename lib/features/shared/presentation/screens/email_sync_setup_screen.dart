import 'package:crm_app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared.dart';

class EmailSyncSetupScreen extends StatelessWidget {
  const EmailSyncSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Conecta tu cuenta para enviar correos y sincronizar tu calendario de forma segura.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: secondaryColor, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              const EmailSyncSetupContent(),
              const SizedBox(height: 12),
              const Text(
                'Presiona "!Empieza ya!" para continuar con la configuracion de Microsoft.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: secondaryColor, height: 1.35),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/microsoft_sync_welcome'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: primaryColor,
                  ),
                  child: const Text('!Empieza ya!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

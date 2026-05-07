import 'package:crm_app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MicrosoftSyncWelcomeScreen extends StatefulWidget {
  const MicrosoftSyncWelcomeScreen({super.key});

  @override
  State<MicrosoftSyncWelcomeScreen> createState() => _MicrosoftSyncWelcomeScreenState();
}

class _MicrosoftSyncWelcomeScreenState extends State<MicrosoftSyncWelcomeScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 8),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mail_outline_rounded, color: secondaryColor, size: 52),
              ),
              const SizedBox(height: 16),
              const Text('Welcome', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: secondaryColor)),
              const SizedBox(height: 8),
              const Text('Synchronize Microsoft email', style: TextStyle(fontSize: 18, color: secondaryColor)),
              const SizedBox(height: 8),
              const Text(
                'Ingresa el correo que deseas conectar. En el siguiente paso te enviaremos al inicio de sesion de Microsoft.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: secondaryColor, height: 1.35),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Correo',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    context.push('/microsoft_login', extra: email);
                  },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

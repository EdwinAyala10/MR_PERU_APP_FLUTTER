import 'package:crm_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailSyncDialog extends StatelessWidget {
  final String message;

  const EmailSyncDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.4),
      ),
      actions: [
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/email_sync_setup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: primaryColor,
                  fixedSize: const Size(220, 44),
                ),
                child: const Text('Ir a la configuracion'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: primaryColor,
                  fixedSize: const Size(220, 44),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

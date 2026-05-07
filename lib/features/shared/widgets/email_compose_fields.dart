import 'package:flutter/material.dart';

class EmailComposeFields extends StatelessWidget {
  final String toEmail;
  final TextEditingController subjectController;
  const EmailComposeFields({
    super.key,
    required this.toEmail,
    required this.subjectController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Para', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(initialValue: toEmail, enabled: false),
          const SizedBox(height: 12),
          const Text('Asunto', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(controller: subjectController),
        ],
      ),
    );
  }
}

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8DD).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: Color(0xFF00607D),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Para',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF00607D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: toEmail,
            enabled: false,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8DD).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.subject_rounded,
                  size: 14,
                  color: Color(0xFF00607D),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Asunto',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF00607D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: subjectController,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
            ),
            decoration: InputDecoration(
              hintText: 'Ingrese el asunto del correo',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00A8DD), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

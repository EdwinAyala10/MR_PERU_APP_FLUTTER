import 'package:flutter/material.dart';
import 'package:crm_app/config/theme/app_theme.dart';
import 'email_recipients_chips.dart';

class EmailComposeFieldsChips extends StatefulWidget {
  final List<EmailRecipientData> toRecipients;
  final List<EmailRecipientData> ccRecipients;
  final List<EmailRecipientData> bccRecipients;
  final Function(EmailRecipientData) onAddTo;
  final Function(int) onRemoveTo;
  final Function(EmailRecipientData) onAddCc;
  final Function(int) onRemoveCc;
  final Function(EmailRecipientData) onAddBcc;
  final Function(int) onRemoveBcc;
  final TextEditingController subjectController;

  const EmailComposeFieldsChips({
    super.key,
    required this.toRecipients,
    required this.ccRecipients,
    required this.bccRecipients,
    required this.onAddTo,
    required this.onRemoveTo,
    required this.onAddCc,
    required this.onRemoveCc,
    required this.onAddBcc,
    required this.onRemoveBcc,
    required this.subjectController,
  });

  @override
  State<EmailComposeFieldsChips> createState() => _EmailComposeFieldsChipsState();
}

class _EmailComposeFieldsChipsState extends State<EmailComposeFieldsChips> {
  bool _ccExpanded = false;
  bool _bccExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TO (siempre visible)
          EmailRecipientsChips(
            label: 'Para',
            hint: 'Agrega destinatarios principales',
            recipients: widget.toRecipients,
            onAdd: widget.onAddTo,
            onRemove: widget.onRemoveTo,
            chipColor: primaryColor,
          ),

          // CC (colapsable)
          EmailRecipientsChips(
            label: 'CC',
            hint: 'Agrega destinatarios con copia',
            recipients: widget.ccRecipients,
            onAdd: widget.onAddCc,
            onRemove: widget.onRemoveCc,
            chipColor: Colors.grey.shade700,
            isExpanded: _ccExpanded || widget.ccRecipients.isNotEmpty,
            onToggle: () => setState(() => _ccExpanded = !_ccExpanded),
          ),

          // BCC (colapsable)
          EmailRecipientsChips(
            label: 'BCC',
            hint: 'Agrega destinatarios con copia oculta',
            recipients: widget.bccRecipients,
            onAdd: widget.onAddBcc,
            onRemove: widget.onRemoveBcc,
            chipColor: Colors.grey.shade700,
            isExpanded: _bccExpanded || widget.bccRecipients.isNotEmpty,
            onToggle: () => setState(() => _bccExpanded = !_bccExpanded),
          ),

          const SizedBox(height: 16),

          // Campo Asunto
          Row(
            children: [
              Icon(
                Icons.subject_rounded,
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Asunto',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.subjectController,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              letterSpacing: 0.1,
            ),
            decoration: InputDecoration(
              hintText: 'Ingrese el asunto del correo',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

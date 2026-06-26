import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;

  const ConfirmDeleteDialog({
    Key? key,
    this.title = 'Eliminar registro',
    required this.message,
    this.confirmLabel = 'Eliminar',
    this.cancelLabel = 'Cancelar',
    this.icon = Icons.delete_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.red.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

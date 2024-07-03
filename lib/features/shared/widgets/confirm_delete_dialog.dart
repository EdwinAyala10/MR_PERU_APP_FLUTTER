import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String message;
  final Function onConfirm;

  const ConfirmDeleteDialog({
    Key? key,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmación"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el dialogo
          },
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(); // Cerrar el dialogo después de confirmar
          },
          child: const Text("Eliminar"),
        ),
      ],
    );
  }
}

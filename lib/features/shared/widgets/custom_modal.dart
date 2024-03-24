import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  String title;
  String description;

  CustomModal({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(description),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el modal
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

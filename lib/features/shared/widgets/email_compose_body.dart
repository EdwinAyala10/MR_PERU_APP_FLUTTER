import 'package:flutter/material.dart';

class EmailComposeBody extends StatelessWidget {
  final TextEditingController controller;
  const EmailComposeBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cuerpo del correo', style: TextStyle(fontWeight: FontWeight.w600)),
          const Divider(),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Escribe aqui...'),
            ),
          ),
        ],
      ),
    );
  }
}

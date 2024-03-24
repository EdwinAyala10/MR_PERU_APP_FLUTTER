import 'package:flutter/material.dart';

class TitleSectionForm extends StatelessWidget {
  String title;

  TitleSectionForm({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
      ],
    );
  }
}

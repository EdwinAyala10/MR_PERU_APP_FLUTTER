import 'package:flutter/material.dart';

class TextViewCustom extends StatelessWidget {
  String label;
  String text;
  String placeholder;

  TextViewCustom({super.key, required this.text, required this.placeholder,required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          child: Text(
            text == "" ? placeholder ?? '' : text,
            style:  TextStyle(
              fontSize: 16.0,
              color: text == "" ? Colors.black45 : Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}

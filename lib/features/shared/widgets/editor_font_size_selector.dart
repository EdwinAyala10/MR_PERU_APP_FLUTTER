import 'package:flutter/material.dart';

/// Selector de tamaño de fuente para el editor
class EditorFontSizeSelector extends StatelessWidget {
  final double currentSize;
  final ValueChanged<double> onSizeChanged;

  const EditorFontSizeSelector({
    super.key,
    required this.currentSize,
    required this.onSizeChanged,
  });

  static const List<double> _availableSizes = [
    10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<double>(
        value: currentSize,
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        items: _availableSizes.map((size) {
          return DropdownMenuItem<double>(
            value: size,
            child: Text('${size.toInt()}'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onSizeChanged(value);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Selector de color de texto para el editor
class EditorColorPicker extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const EditorColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  static const List<Color> _availableColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Color(0xFF00A8DD), // Primary color
    Color(0xFF00607D), // Secondary color
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showColorDialog(context),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.format_color_text,
              size: 16,
              color: currentColor,
            ),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            final isSelected = currentColor == color;
            return InkWell(
              onTap: () {
                onColorChanged(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

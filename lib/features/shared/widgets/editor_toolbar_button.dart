import 'package:flutter/material.dart';

/// Botón reutilizable para la toolbar del editor
class EditorToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final String tooltip;

  const EditorToolbarButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive 
                ? const Color(0xFF00A8DD).withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: isActive ? const Color(0xFF00A8DD) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? const Color(0xFF00A8DD) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

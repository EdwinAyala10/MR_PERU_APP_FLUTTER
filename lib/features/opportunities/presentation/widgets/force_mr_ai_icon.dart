import 'package:flutter/material.dart';

class ForceMrAiIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const ForceMrAiIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/logomrIA.png',
      width: size,
      height: size,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon si la imagen no se carga
        return Icon(
          Icons.auto_awesome_rounded,
          size: size,
          color: color ?? const Color(0xFF00A8DD),
        );
      },
    );
  }
}

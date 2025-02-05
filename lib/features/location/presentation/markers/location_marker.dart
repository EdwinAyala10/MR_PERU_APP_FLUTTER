import 'package:crm_app/config/config.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LocationMarkerPainter extends CustomPainter {

  LocationMarkerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()..color = Colors.red;
    final orangePaint = Paint()..color = primaryColor;
    final whitePaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const double circleBlueRadius = 12;
    const double circleWhiteRadius = 8;

    // Círculo Azul
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height - circleBlueRadius),
      circleBlueRadius,
      bluePaint,
    );

    // Círculo Blanco
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height - circleBlueRadius),
      circleWhiteRadius,
      whitePaint,
    );


    // Marcador Naranja con borde blanco
    const markerWidth = 25.0; // Reducir el ancho del marcador
    const markerHeight = 60.0; // Ajustar la altura del marcador
    final double centerX = size.width * 0.5;
    final double centerY = size.height - circleBlueRadius * 2 - markerHeight * 0.5 - 16;

    final markerPath = Path()
      ..moveTo(centerX, centerY)
      ..arcToPoint(
        Offset(centerX - markerWidth * 0.5, centerY + markerHeight * 0.5),
        radius: const Radius.circular(markerWidth * 0.7),
        clockwise: false,
      )
      ..lineTo(centerX, centerY + markerHeight * 0.7)
      ..lineTo(centerX + markerWidth * 0.5, centerY + markerHeight * 0.5)
      ..arcToPoint(
        Offset(centerX, centerY),
        radius: const Radius.circular(markerWidth * 0.7),
        clockwise: false,
      )
      ..close();

    // Dibuja el marcador naranja
    canvas.drawPath(markerPath, orangePaint);
    // Dibuja el borde blanco
    canvas.drawPath(markerPath, borderPaint);

    // Dibuja el ícono del calendario en el centro del marcador naranja
    const iconSize = 20.0;
    const icon = Icons.person_2_rounded;

    final textSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );

    final textPainterIcon = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainterIcon.layout();
    textPainterIcon.paint(
      canvas,
      Offset(
        centerX - textPainterIcon.width / 2,
        centerY - textPainterIcon.height / 2 + 16, // Ajustar la posición vertical
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
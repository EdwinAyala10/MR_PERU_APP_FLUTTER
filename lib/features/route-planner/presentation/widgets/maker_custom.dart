import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = Colors.red;

  const double markerWidth = 200.0;
  const double markerHeight = 150.0;

  // Define the custom marker shape
  Path path = Path()
    ..moveTo(markerWidth / 2, markerHeight)
    ..lineTo(markerWidth, markerHeight / 2)
    ..lineTo(markerWidth / 2, 0)
    ..lineTo(0, markerHeight / 2)
    ..close();

  canvas.drawPath(path, paint);

  // Draw text
  TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 30.0,
        color: Colors.white,
      ),
    ),
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(markerWidth / 2 - textPainter.width / 2, markerHeight / 2 - textPainter.height / 2),
  );

  final ui.Image markerAsImage = await pictureRecorder
      .endRecording()
      .toImage(markerWidth.toInt(), markerHeight.toInt());
  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List);
}

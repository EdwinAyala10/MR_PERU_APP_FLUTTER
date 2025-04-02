import 'dart:ui' as ui;

import 'package:crm_app/features/location/presentation/markers/markers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


Future<BitmapDescriptor> getLocationCustomMarker() async {

  final recoder = ui.PictureRecorder();
  final canvas = ui.Canvas( recoder );
  const size = ui.Size(350, 150);

  final startMarker = LocationMarkerPainter();
  startMarker.paint(canvas, size);

  final picture = recoder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData( format: ui.ImageByteFormat.png );

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());

}

Future<BitmapDescriptor> getCustomMarker( int number ) async {

  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  const size = Size(100, 100); // Ajusta el tamaño según sea necesario

  CustomMarkerPainter(number: number).paint(canvas, size);

  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(buffer);

}


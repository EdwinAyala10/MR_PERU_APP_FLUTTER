// utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

void mostrarModalMensaje(BuildContext context, String titulo, String descripcion, Function() onAceptar) {
  if (Platform.isAndroid) {
    // Mostrar estilo Android
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                descripcion,
                style: const TextStyle(fontSize: 16),
              ),
              /*const SizedBox(height: 20),
              const Icon(
                Icons.info,
                color: Colors.blue,
                size: 50,
              ),*/
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: onAceptar
            ),
            /*TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),*/
          ],
        );
      },
    );
  } else {
    // Mostrar estilo iOS
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(titulo),
          content: Column(
            children: [
              Text(descripcion),
              /*const SizedBox(height: 20),
              const Icon(
                CupertinoIcons.info,
                color: CupertinoColors.activeBlue,
                size: 50,
              ),*/
            ],
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            /*CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),*/
          ],
        );
      },
    );
  }
}
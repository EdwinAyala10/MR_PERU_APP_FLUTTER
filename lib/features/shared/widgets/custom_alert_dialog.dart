import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class CustomAlertDialogPro extends StatelessWidget {
  final BuildContext parentContext;
  final String title;
  final String message;
  final String buttonText;

  CustomAlertDialogPro({
    required this.parentContext,
    required this.title,
    required this.message,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _buildCupertinoDialog()
        : _buildMaterialDialog();
  }

  Widget _buildMaterialDialog() {
    print('ALERT ANDORID');
    return AlertDialog(
      title: Center(child: Text(title)),
      content: Text(message),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(parentContext).pop(); // Cierra el diálogo
            },
            child: Text(buttonText),
          ),
        ),
      ],
    );
  }

  Widget _buildCupertinoDialog() {
    print('ALERT IOS');
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(parentContext).pop(); // Cierra el diálogo
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}

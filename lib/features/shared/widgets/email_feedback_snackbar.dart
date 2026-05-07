import 'package:crm_app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmailFeedbackSnackbar {
  static void showEmailSent(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tu correo electronico ha sido enviado con exito',
          style: TextStyle(fontSize: 13),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 690),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  static void showSyncSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta sincronizada correctamente')),
    );
  }
}

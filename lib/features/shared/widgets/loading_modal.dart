import 'package:flutter/material.dart';

class LoadingModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // ModalBarrier oscurece el fondo para evitar interacción
        ModalBarrier(
          color: Colors.black.withOpacity(0.5), // Opacidad del oscurecimiento
          dismissible: false, // No permite cerrar con tap fuera del modal
        ),
        Center(
          child: CircularProgressIndicator(), // Indicador de carga circular
        ),
      ],
    );
  }
}

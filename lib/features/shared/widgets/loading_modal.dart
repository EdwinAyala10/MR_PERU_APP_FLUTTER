
import 'package:flutter/material.dart';

class LoadingModal extends StatelessWidget {
  const LoadingModal({super.key});

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
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Cambia el color del indicador de carga
                ),
                SizedBox(height: 16.0),
                Text(
                  'Cargando...', // Mensaje de carga
                  style: TextStyle(fontSize: 13.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

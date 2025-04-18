import 'package:crm_app/config/config.dart';
import 'package:flutter/material.dart';

class FloatingActionButtonIconCustom extends StatelessWidget {
  final String label;
  final IconData iconData;
  final Function()? callOnPressed;

  const FloatingActionButtonIconCustom({super.key, 
    required this.label,
    required this.callOnPressed,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: callOnPressed,
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0), // Ajusta el radio para cambiar el tamaño del borde redondeado
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white // Tamaño de fuente ajustable según tus necesidades
              ),
            ),
          ),
          Icon(
            iconData,
            color: Colors.white,
            size: 28, // Tamaño del icono ajustable según tus necesidades
          ),
        ],
      ),
    );
  }
}

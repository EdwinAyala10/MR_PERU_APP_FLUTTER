import 'package:flutter/material.dart';

class EmailSyncSetupContent extends StatelessWidget {
  const EmailSyncSetupContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Sincronizacion de correo y calendario',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Al activarla, la sincronizacion bidireccional sincronizara los eventos entre Sage Sales Management y su proveedor de calendario, replicandolos en ambas direcciones.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ],
    );
  }
}

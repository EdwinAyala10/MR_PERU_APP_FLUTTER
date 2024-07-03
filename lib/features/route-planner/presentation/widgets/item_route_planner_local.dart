import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';

import 'package:flutter/material.dart';

class ItemRoutePlannerLocal extends StatelessWidget {
  CompanyLocalRoutePlanner local;
  final Function()? callbackOnTap;

  ItemRoutePlannerLocal({super.key, required this.local, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    int? numCantidadLocal = int.tryParse(local.localCantidad ?? '0');
    numCantidadLocal = numCantidadLocal ?? 0;

    return ListTile(
      title: Text(local.localNombre,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(local.razon ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),  
          Row(
            children: [
              Text(local.clienteNombreEstado ?? ''),
              const Text(' - '),
              Text(local.clienteNombreTipo ?? ''),
            ],
          ),
          Text ((numCantidadLocal>1 ? local.localDistrito : local.localDireccion) ?? '' , style: const TextStyle(color: Colors.black45))
        ],
      ),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: secondaryColor,
            ),
            child: const Icon(
              Icons.business,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(local.calificacion ?? ''),
          Text(local.userreportName ?? '')
        ],
      ),
      onTap: callbackOnTap,
    );
  }
}

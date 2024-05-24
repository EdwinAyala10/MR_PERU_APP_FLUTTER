import '../../domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompany extends StatelessWidget {
  Company company;
  final Function()? callbackOnTap;

  ItemCompany({super.key, required this.company, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    int? numCantidadLocal = int.tryParse(company.localCantidad ?? '0');
    numCantidadLocal = numCantidadLocal ?? 0;

    return ListTile(
      title: Text(company.razon,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(company.clienteNombreEstado ?? ''),
              const Text(' - '),
              Text(company.clienteNombreTipo ?? ''),
            ],
          ),
          Text ((numCantidadLocal>1 ? company.localDistrito : company.localDireccion) ?? '' , style: const TextStyle(color: Colors.black45))
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
              color: Colors.black12,
            ),
            child: const Icon(
              Icons.business,
              size: 24,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.thumb_up,
              size: 24,
              color: company.clienteNombreEstado == 'ACTIVO'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(company.calificacion ?? ''),
          Text(company.userreporteName ?? '')
        ],
      ),
      onTap: callbackOnTap,
    );
  }
}

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompany extends StatelessWidget {
  Company company;
  final Function()? callbackOnTap;

  ItemCompany({super.key, required this.company, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(company.razon, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(company.estado ?? ''),
              Text(' - '),
              Text(company.tipocliente ?? ''),
            ],
          ),
          Text(company.direccion ?? '', style: TextStyle( color: Colors.black45 ))
        ],
      ),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50, // Ancho del contenedor circular
            height: 60, // Altura del contenedor circular
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black12, // Color del contenedor circular
            ),
            child: const Icon(
              Icons.business,
              size: 24, // Tamaño del icono del edificio
              color: Colors.white, // Color del icono del edificio
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.thumb_up,
              size: 24, // Tamaño del icono de la mano
              color: company.estado == 'ACTIVO' ? Colors.green : Colors.red, // Color del icono de la mano
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(company.calificacion ?? ''),
          Text('[Responsable]')
        ],
      ),
      onTap: callbackOnTap,
    );
  }
}

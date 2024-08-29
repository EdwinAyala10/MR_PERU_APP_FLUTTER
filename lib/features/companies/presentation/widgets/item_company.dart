import 'package:crm_app/config/config.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompany extends StatelessWidget {
  Company company;
  int index;
  final Function()? callbackOnTap;

  ItemCompany({super.key, required this.company, required this.callbackOnTap, required this.index});

  @override
  Widget build(BuildContext context) {
    int? numCantidadLocal = int.tryParse(company.localCantidad ?? '0');
    numCantidadLocal = numCantidadLocal ?? 0;

    return ListTile(
      title: Text('${index} - ${company.razon}',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (company.razonComercial != "")
            Text(
              '${company.razonComercial}',
              style: const TextStyle(
                color: primaryColor,
              ),
            ),
          Row(
            children: [
              Text(company.clienteNombreEstado ?? ''),
              const Text(' - '),
              Text(company.clienteNombreTipo ?? ''),
            ],
          ),
          Text(
              (numCantidadLocal > 1
                      ? company.localDistrito
                      : company.localDireccion) ??
                  '',
              style: const TextStyle(color: Colors.black45))
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
          SizedBox(
              width: 100,
              child: Text(
                company.calificacion ?? '',
                style: TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis),
              )),
          Text(company.userreporteName ?? '')
        ],
      ),
      onTap: callbackOnTap,
    );
  }
}

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompanyLocal extends StatelessWidget {
  CompanyLocal companyLocal;
  final Function()? callbackOnTap;

  ItemCompanyLocal({super.key, required this.companyLocal, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(companyLocal.localNombre == "" ? "SIN NOMBRE" : companyLocal.localNombre , style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(companyLocal.localDireccion == "" ? "SIN DIRECCION" : companyLocal.localDireccion ?? ''),
          Text(companyLocal.localTipo ?? '', style: const TextStyle( color: Colors.black45 )),
          Text('ID: ${companyLocal.id}')
        ],
      ),
      leading: const Icon(Icons.home_work_outlined),
      onTap: callbackOnTap,
    );
  }
}

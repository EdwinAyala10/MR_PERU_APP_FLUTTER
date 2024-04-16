import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompanyLocal extends StatelessWidget {
  CompanyLocal companyLocal;
  final Function()? callbackOnTap;

  ItemCompanyLocal({super.key, required this.companyLocal, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        companyLocal.localNombre == "" ? "LOCAL SIN NOMBRE" : companyLocal.localNombre , 
        style: TextStyle(fontWeight: FontWeight.w500, color: companyLocal.localNombre == "" ? Colors.black45: Colors.black)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(companyLocal.localTipoDescripcion ?? '', style: const TextStyle( color: Colors.black45 )),
          Text(companyLocal.localDireccion == "" ? "SIN DIRECCION" : companyLocal.localDireccion ?? ''),
          Text('${companyLocal.departamento} - ${companyLocal.provincia} - ${companyLocal.distrito}'),
        ],
      ),
      leading: const Icon(Icons.home_work_outlined),
      trailing: GestureDetector(
        onTap: callbackOnTap,
        child: const Icon(Icons.place, size: 38, color: Colors.deepOrangeAccent),
      ),
      //onTap: ,
    );
  }
}

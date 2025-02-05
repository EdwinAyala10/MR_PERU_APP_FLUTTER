import '../../domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompanyLocal extends StatelessWidget {
  CompanyLocal companyLocal;
  final Function()? callbackOnTap;
  final Function()? editCallOnTap;
  final bool isAdmin;

  ItemCompanyLocal(
      {super.key,
      required this.companyLocal,
      required this.callbackOnTap,
      required this.editCallOnTap,
      required this.isAdmin,
    });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //onTap: editCallOnTap,
      title: Text(
          companyLocal.localNombre == ""
              ? "LOCAL SIN NOMBRE"
              : companyLocal.localNombre,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: companyLocal.localNombre == ""
                  ? Colors.black45
                  : Colors.black)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (companyLocal.coordenadasLatitud == "")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Sin coordenadas',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Text(companyLocal.localTipoDescripcion ?? '',
              style: const TextStyle(color: Colors.black45)),
          Text(companyLocal.localDireccion == ""
              ? "SIN DIRECCION"
              : companyLocal.localDireccion ?? ''),
          Text(
              '${companyLocal.departamento} - ${companyLocal.provincia} - ${companyLocal.distrito}'),
        ],
      ),
      leading: const Icon(
        Icons.home_work_outlined,
        size: 34,
      ),
      trailing: Column(
        children: [
          GestureDetector(
            onTap: isAdmin ? editCallOnTap : null,
            child: Icon(Icons.edit,
                size: 24, 
                color: isAdmin ? Color.fromARGB(255, 45, 45, 45) :Color.fromARGB(255, 211, 203, 203)
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: companyLocal.coordenadasLatitud == "" ? null : callbackOnTap,
            child: Icon(Icons.place,
                size: 24,
                color: companyLocal.coordenadasLatitud == ""
                    ? const Color.fromARGB(255, 239, 210, 200)
                    : Colors.deepOrangeAccent),
          ),
        ],
      ),
      //onTap: ,
    );
  }
}

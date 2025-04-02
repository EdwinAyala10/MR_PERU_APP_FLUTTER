import 'package:crm_app/config/config.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompanyLocal extends StatelessWidget {
  final CompanyLocal companyLocal;
  final Function()? callbackOnTap;
  final Function()? editCallOnTap;
  final Function()? programCallOnTap;
  final bool isAdmin;

  const ItemCompanyLocal({
    super.key,
    required this.companyLocal,
    required this.callbackOnTap,
    required this.editCallOnTap,
    required this.isAdmin,
    required this.programCallOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListTile(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                child: Icon(
                  Icons.edit,
                  size: 24,
                  color: isAdmin
                      ? const Color.fromARGB(255, 45, 45, 45)
                      : const Color.fromARGB(255, 211, 203, 203),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: companyLocal.coordenadasLatitud == ""
                    ? null
                    : callbackOnTap,
                child: Icon(
                  Icons.place,
                  size: 24,
                  color: companyLocal.coordenadasLatitud == ""
                      ? const Color.fromARGB(255, 239, 210, 200)
                      : Colors.deepOrangeAccent,
                ),
              ),
            ],
          ),
          //onTap: ,
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: MaterialButton(
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Programar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (programCallOnTap != null) {
                programCallOnTap!();
              }
            },
          ),
        )
      ],
    );
  }
}

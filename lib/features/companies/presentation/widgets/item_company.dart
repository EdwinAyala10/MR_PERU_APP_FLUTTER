import 'package:crm_app/config/config.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';

class ItemCompany extends StatelessWidget {
  final Company company;
  final Function()? callbackOnTap;
  final bool isEmpresasScreen;

  const ItemCompany(
      {super.key,
      required this.company,
      required this.callbackOnTap,
      this.isEmpresasScreen = false});

  @override
  Widget build(BuildContext context) {
    int? numCantidadLocal = int.tryParse(company.localCantidad ?? '0');
    numCantidadLocal = numCantidadLocal ?? 0;

    return Container(
      color: isEmpresasScreen
          ? company.estadoCliente != 'A'
              ? Colors.yellow[50]
              : Colors.transparent
          : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        title: Text(company.razon,
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
                style: const TextStyle(color: Colors.black45)),

            // Último comentario actividad
            Visibility(
              visible: company.actiComentario != null &&
                  company.actiComentario != '',
              child: Row(
                children: [
                  const Icon(Icons.mode_comment, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${company.actiComentario}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
            // Última visita
            if (company.cchkUltimaVisita != null &&
                company.cchkUltimaVisita!.isNotEmpty)
              ...company.cchkUltimaVisita!.map(
                (cchk) => Column(
                  children: [
                    Visibility(
                      visible: cchk.cchkFechaRegistroCheckIn != null &&
                          cchk.cchkFechaRegistroCheckIn != '',
                      child: Text(
                        'Últ. visita: ${cchk.cchkFechaRegistroCheckIn}',
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    // Último check-in
                    Visibility(
                      visible: cchk.cchkComentarioCheckIn != null &&
                          cchk.cchkComentarioCheckIn != '',
                      child: Row(
                        children: [
                          const Icon(Icons.mode_comment, size: 14),
                          const Icon(Icons.keyboard_arrow_right_rounded,
                              size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Últ. check-in: ${cchk.cchkComentarioCheckIn}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Último check-out
                    Visibility(
                      visible: cchk.cchkComentarioCheckOut != null &&
                          cchk.cchkComentarioCheckOut != '',
                      child: Row(
                        children: [
                          const Icon(Icons.mode_comment, size: 14),
                          const Icon(Icons.keyboard_arrow_left_rounded,
                              size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Últ. check-out: ${cchk.cchkComentarioCheckOut}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                  style: const TextStyle(
                      fontSize: 10, overflow: TextOverflow.ellipsis),
                )),
            Text(company.userreporteName ?? '')
          ],
        ),
        onTap: callbackOnTap,
      ),
    );
  }
}

import 'package:crm_app/config/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemEvent extends StatelessWidget {
  final Event event;
  final Function()? callbackOnTap;

  const ItemEvent({super.key, required this.event, this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            ListTile(
              // onTap: callbackOnTap,
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      DateFormat('hh:mm a').format(
                          event.evntHoraInicioEvento != null
                              ? DateFormat('HH:mm:ss')
                                  .parse(event.evntHoraInicioEvento ?? '')
                              : DateTime.now()),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                      DateFormat('hh:mm a').format(
                          event.evntHoraFinEvento != null
                              ? DateFormat('HH:mm:ss')
                                  .parse(event.evntHoraFinEvento ?? '')
                              : DateTime.now()),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.evntRazon}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text('${event.evntRazonComercial}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: primaryColor)),
                  Text(
                    event.evntAsunto,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${event.evntNombreTipoGestion}',
                    style: const TextStyle(fontSize: 13,color: Colors.black),
                  ),
                  Visibility(
                    visible: event.cckkIdEstadoCheck == 'Visitado',
                    child: Container(
                      // padding: EdgeInsets.all(4),
                      // decoration: BoxDecoration(
                      //   color: const Color.fromARGB(255, 136, 155, 165),
                      //   borderRadius: BorderRadius.circular(25)
                      // ),
                      child: Text(
                        '${event.cchkFechaRegistroCheckIn}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -1,
              right: 15,
              top: event.cckkIdEstadoCheck == 'Visitado' ? null : 35,
              child: Column(
                children: [
                  Visibility(
                    visible: event.cckkIdEstadoCheck == 'Visitado',
                    child: MaterialButton(
                      onPressed: () {},
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      color: Colors.green,
                      child: Text(
                        event.cckkIdEstadoCheck ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    color: primaryColor,
                    onPressed: callbackOnTap,
                    child: const Text(
                      'CHECK-IN',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/shared/widgets/capitalize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemEvent extends StatelessWidget {
  final Event event;
  final Function()? callbackOnTap;
  final Function()? callbackChekIn;
  final bool isMainScreen;

  const ItemEvent(
      {super.key,
      required this.event,
      this.callbackOnTap,
      this.callbackChekIn,
      this.isMainScreen = true});

  @override
  Widget build(BuildContext context) {
    String evntFechaInicioEventoFormatted = DateFormat.yMMMMEEEEd('es')
        .format(event.evntFechaInicioEvento ?? DateTime.now());

    return Column(
      children: [
        Stack(
          children: [
            ListTile(
              onTap: callbackOnTap,
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
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(event.evntHoraFinEvento != null
                        ? DateFormat('HH:mm:ss')
                            .parse(event.evntHoraFinEvento ?? '')
                        : DateTime.now()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalize(evntFechaInicioEventoFormatted),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
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

                  /// SHOW DIRECTION OF EVENT IN MAP
                  Text(
                    '${event.localDirection}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: primaryColor,
                    ),
                  ),
                  Visibility(
                    visible: event.evntNombreTipoGestion == '' ? false : true,
                    child: Text(
                      '${event.evntNombreTipoGestion}',
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ),
                  // Visibility(
                  //   visible: event.cckkIdEstadoCheck == 'VISITADO',
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(25),
                  //       color: Colors.white,
                  //     ),
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 10,
                  //       vertical: 2,
                  //     ),
                  //     child: Text(
                  //       event.cckkIdEstadoCheck ?? '',
                  //       style:
                  //           const TextStyle(color: primaryColor, fontSize: 14),
                  //     ),
                  //   ),
                  // ),
                  // Visibility(
                  //   visible: event.cckkIdEstadoCheck == 'VISITADO',
                  //   child: Text(
                  //     '${event.cchkFechaRegistroCheckIn}',
                  //     style: const TextStyle(fontSize: 13, color: Colors.black),
                  //   ),
                  // ),
                  Visibility(
                    visible: event.cchkFechaRegistroCheckIn != null &&
                        event.cchkFechaRegistroCheckIn != '',
                    child: Text(
                      'Últ. visita: ${event.cchkFechaRegistroCheckIn}',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Visibility(
                    visible: event.cchkComentarioCheckIn != null &&
                        event.cchkComentarioCheckIn != '',
                    child: Row(
                      children: [
                        const Icon(Icons.mode_comment, size: 14),
                        const Icon(Icons.keyboard_arrow_right_rounded,
                            size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Últ. check-in: ${event.cchkComentarioCheckIn}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: event.cchkComentarioCheckOut != null &&
                        event.cchkComentarioCheckOut != '',
                    child: Row(
                      children: [
                        const Icon(Icons.mode_comment, size: 14),
                        const Icon(Icons.keyboard_arrow_left_rounded, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Últ. check-out: ${event.cchkComentarioCheckOut}',
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
            Positioned(
              bottom: 10,
              right: 10,
              // top: event.cckkIdEstadoCheck == 'Visitado' ? null : 35,
              child: Column(
                children: [
                  // Visibility(
                  //   visible: event.cckkIdEstadoCheck == 'Visitado',
                  //   child: const Padding(
                  //     padding: EdgeInsets.only(bottom: 10, right: 20),
                  //     child: CircleAvatar(
                  //       radius: 28,
                  //       backgroundColor: Colors.green,
                  //       child: Icon(
                  //         Icons.check,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Visibility(
                    visible: event.cckkIdEstadoCheck == 'VISITADO',
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      color: Colors.green,
                      onPressed: () {},
                      child: Text(
                        event.cckkIdEstadoCheck ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: event.cckkIdEstadoCheck != 'VISITADO',
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      color: primaryColor,
                      onPressed: callbackChekIn,
                      child: const Text(
                        'CHECK-IN',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: primaryColor,
                    onPressed: () async {
                      final lat = event.evntCoordenadaLatitud;
                      final lng = event.evntCoordenadaLongitud;
                      final url =
                          'https://www.waze.com/ul?ll=$lat,$lng&navigate=yes';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        // Maneja el caso en que Waze no esté instalado, por ejemplo, redirigiendo a la App Store
                        throw 'No se pudo lanzar $url';
                      }
                    },
                    child: const Text(
                      'WAZE',
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

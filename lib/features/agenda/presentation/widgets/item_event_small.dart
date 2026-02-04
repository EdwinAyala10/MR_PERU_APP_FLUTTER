import 'package:crm_app/config/theme/app_theme.dart';

import '../../domain/domain.dart';
import '../../../shared/widgets/capitalize.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemEventSmall extends StatelessWidget {
  final Event event;
  final Function()? callbackOnTap;

  const ItemEventSmall({super.key, required this.event, this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    String evntFechaInicioEventoFormatted = DateFormat.yMMMMEEEEd('es')
        .format(event.evntFechaInicioEvento ?? DateTime.now());

    return ListTile(
      onTap: callbackOnTap,
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              DateFormat('hh:mm a').format(event.evntHoraInicioEvento != null
                  ? DateFormat('HH:mm:ss')
                      .parse(event.evntHoraInicioEvento ?? '')
                  : DateTime.now()),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
              DateFormat('hh:mm a').format(event.evntHoraFinEvento != null
                  ? DateFormat('HH:mm:ss').parse(event.evntHoraFinEvento ?? '')
                  : DateTime.now()),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      dense: true,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            capitalize(evntFechaInicioEventoFormatted),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          showTextIfNotEmpty(event.evntRazon),
          Text('${event.evntRazonComercial}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: primaryColor)),
          Text(event.evntAsunto,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Expanded(
                  child: Text(
                '${event.localDirection}',
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: primaryColor,
                ),
              )),
            ],
          ),
          Visibility(
            visible: event.cchkFechaRegistroCheckIn != null &&
                event.cchkFechaRegistroCheckIn != '',
            child: Text(
              'Últ. visita: ${event.cchkFechaRegistroCheckIn}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ),
          Visibility(
            visible: event.cchkComentarioCheckIn != null &&
                event.cchkComentarioCheckIn != '',
            child: Row(
              children: [
                const Icon(Icons.mode_comment, size: 14),
                const Icon(Icons.keyboard_arrow_right_rounded, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(event.cchkComentarioCheckIn ?? '',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis)),
                )
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
                    child: Text(event.cchkComentarioCheckOut ?? '',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis)),
                  )
                ],
              )),
        ],
      ),
    );
  }

  Widget showTextIfNotEmpty(String? text) {
    return text != null && text.isNotEmpty
        ? Text(text,
            style:
                const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis))
        : const SizedBox.shrink();
  }
}

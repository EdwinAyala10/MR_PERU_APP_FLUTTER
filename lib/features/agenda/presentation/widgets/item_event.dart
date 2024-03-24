import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ItemEvent extends StatelessWidget {
  final Event event;
  final Function()? callbackOnTap;

  const ItemEvent({super.key, required this.event, this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                  DateFormat('hh:mm a').format(
                      event.evntHoraFinEvento != null
                          ? DateFormat('HH:mm:ss')
                              .parse(event.evntHoraInicioEvento ?? '')
                          : DateTime.now()),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.evntAsunto,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              Text('${event.evntNombreTipoGestion}',
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

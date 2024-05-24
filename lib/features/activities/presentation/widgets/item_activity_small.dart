import '../../domain/domain.dart';
import '../../../shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ItemActivitySmall extends StatelessWidget {
  final Activity activity;
  final Function()? callbackOnTap;

  const ItemActivitySmall({super.key, required this.activity, this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    final DateTime fechaActividad = activity.actiFechaActividad;
    String horaActividad = activity.actiHoraActividad;

    if (horaActividad.length == 8) {
      horaActividad = '$horaActividad.0000000';
    }

    // Combinar fecha y hora
    DateTime fechaHoraActividad = DateTime(
      fechaActividad.year,
      fechaActividad.month,
      fechaActividad.day,
      int.parse(horaActividad.substring(0, 2)),
      int.parse(horaActividad.substring(3, 5)),
      int.parse(horaActividad.substring(6, 8)),
      int.parse(horaActividad.substring(9, 12)),
    );

    // Formatear la fecha
    String formattedDate =
        DateFormat('dd MMM yyyy hh:mm a').format(fechaHoraActividad);

    // Calcular la diferencia de tiempo
    Duration difference = DateTime.now().difference(fechaHoraActividad);
    String timeDifference = formatTimeDifference(difference);

    IconData icono;
    Color color;

    switch (activity.actiIdTipoGestion) {
      case '01':
        icono = Icons.comment;
        color = Colors.blue;
        break;
      case '02':
        icono = Icons.call;
        color = Colors.green;
        break;
      case '03':
        icono = Icons.people;
        color = Colors.orange;
        break;
      case '04':
        icono = Icons.location_on;
        color = Colors.red;
        break;
      case '05':
        icono = Icons.chat;
        color = Colors.green;
        break;
      case '06':
        icono = Icons.phone_forwarded;
        color = Colors.orangeAccent;
        break;
      default:
        icono = Icons.view_kanban_outlined;
        color = Colors.black;
        break;
    }

    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.contactoDesc != "") 
            Text(
              activity.contactoDesc ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          Text(
            activity.actiRazon ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(activity.actiNombreTipoGestion),
          if (activity.actiComentario != "" && activity.actiIdTipoGestion != '04')
            Row(
              children: [
                const Icon(Icons.mode_comment, size: 14),
                const SizedBox(width: 4),
                SizedBox(
                  width: 90,
                  child: Text(activity.actiComentario,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          if (activity.cchkComentarioCheckIn != "" && activity.actiIdTipoGestion == '04')
            Row(
              children: [
                const Icon(Icons.mode_comment, size: 14),
                const Icon(Icons.keyboard_arrow_right_rounded, size: 14),
                const SizedBox(width: 4),
                Text(activity.cchkComentarioCheckIn ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          
          if (activity.cchkComentarioCheckOut != "" && activity.actiIdTipoGestion == '04')
            Row(
              children: [
                const Icon(Icons.mode_comment, size: 14),
                const Icon(Icons.keyboard_arrow_left_rounded, size: 14),

                const SizedBox(width: 4),
                Text(activity.cchkComentarioCheckOut ?? '',
                  style: const TextStyle(
                      fontSize: 12,
                    ),
                  overflow: TextOverflow.ellipsis),
              ],
            ),

          if (activity.actiTiempoGestion != "") 
            Row(
              children: [
                const Icon(Icons.lock_clock, size: 16),
                const SizedBox(width: 4),
                Text(activity.actiTiempoGestion ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis),
              ],
            )
          
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 11, color: Colors.black45, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            height: 12,
            child: Text(activity.actiNombreResponsable ?? '',
                style: const TextStyle(
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis
                )),
          ),
          SizedBox(
            height: 12,
            child: Text(timeDifference,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                )),
          ),
        ],
      ),
      leading: SizedBox(
        width: 10,
        child: Column(
          children: [
            activity.actiIdTipoGestion == '05' 
            ? const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 32,) 
            : Icon(
              //Icons.airline_stops_sharp
              icono, 
              size: 30,
              color: color,
            ),
          ],
        ),
      ),
      onTap: callbackOnTap,
    );
  }
}

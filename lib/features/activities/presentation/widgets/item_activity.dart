import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ItemActivity extends StatelessWidget {
  final Activity activity;
  final Function()? callbackOnTap;

  const ItemActivity({super.key, required this.activity, this.callbackOnTap});

  @override
  Widget build(BuildContext context) {

    final DateTime fechaActividad = activity.actiFechaActividad;
    final String horaActividad = activity.actiHoraActividad;

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
    String formattedDate = DateFormat('dd MMM yyyy hh:mm a').format(fechaHoraActividad);

    // Calcular la diferencia de tiempo
    Duration difference = DateTime.now().difference(fechaHoraActividad);
    String timeDifference = formatTimeDifference(difference);

    return ListTile(
      title: Text(activity.actiRazon ?? '', style: TextStyle( fontWeight: FontWeight.w500 ),),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(activity.actiNombreTipoGestion),
          Text(activity.actiComentario, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formattedDate,
            style: TextStyle(fontSize: 14, color: Colors.black45),
          ),
          Text(
            activity.actiNombreResponsable ?? '', 
            style: TextStyle(
              fontSize: 13,
            )
          ),
          Text(
            timeDifference, 
            style: TextStyle(
              fontSize: 12,
            )
          ),
        ],
      ),
      leading: const Icon(
        //Icons.airline_stops_sharp
        Icons.add_location_alt_sharp
      ),
      onTap: callbackOnTap,
    );
  }
}

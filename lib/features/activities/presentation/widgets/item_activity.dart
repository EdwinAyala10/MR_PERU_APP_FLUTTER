import '../../domain/domain.dart';
import '../../../shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemActivity extends StatelessWidget {
  final Activity activity;
  final Function()? callbackOnTap;

  const ItemActivity({super.key, required this.activity, this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    final bool isEmailActivity = activity.actiIdTipoGestion == '07';
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
              _getContactPrefix(activity),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
             activity.actiIdTipoGestion == '04' ? '${activity.actiRazon} - ${activity.localNombre}' : '${activity.actiRazon}' ,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de actividad (siempre mostrar)
          Text(activity.actiNombreTipoGestion),
          
          if (isEmailActivity)
            Row(
              children: [
                const Icon(Icons.subject, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    (activity.subject?.isNotEmpty == true
                            ? activity.subject
                            : activity.emlsAsunto) ??
                        'Sin asunto',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          if (!isEmailActivity && activity.actiComentario != "" && activity.actiIdTipoGestion != '04')
            Row(
              children: [
                const Icon(Icons.mode_comment, size: 14),
                const SizedBox(width: 4),
                Expanded(
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
                Expanded(
                  child: Text(
                    activity.cchkComentarioCheckIn ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          
          if (activity.cchkComentarioCheckOut != "" && activity.actiIdTipoGestion == '04')
            Row(
              children: [
                const Icon(Icons.mode_comment, size: 14),
                const Icon(Icons.keyboard_arrow_left_rounded, size: 14),

                const SizedBox(width: 4),
                Expanded(
                  child: Text(activity.cchkComentarioCheckOut ?? '',
                    style: const TextStyle(
                        fontSize: 12,
                      ),
                    overflow: TextOverflow.ellipsis),
                ),
              ],
            ),

          if (isEmailActivity)
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            activity.isRead == null
                                ? Icons.close // null = no enviado
                                : activity.isRead == true
                                    ? Icons.visibility // "1" = leído
                                    : Icons.access_time, // "0" = no leído
                            size: 8,
                            color: activity.isRead == null
                                ? Colors.red // null = rojo
                                : activity.isRead == true
                                    ? Colors.green // "1" = verde
                                    : Colors.orange, // "0" = naranja
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (!isEmailActivity && activity.actiTiempoGestion != "") 
            Row(
              children: [
                const Icon(Icons.lock_clock, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(activity.actiTiempoGestion ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis),
                ),
              ],
            )
          
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          Text(activity.actiNombreResponsable ?? '',
              style: const TextStyle(
                fontSize: 10,
              )),
          Text(timeDifference,
              style: const TextStyle(
                fontSize: 10,
              )),
        ],
      ),
      leading: SizedBox(
        child: Column(
          children: [
            const SizedBox(height: 10),
            isEmailActivity
                ? SizedBox(
                    width: 30,
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.email,
                          size: 26,
                          color: Colors.grey,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity.emlsIdTipoMailfolders == '02'
                                  ? Icons.north_east
                                  : Icons.south_west,
                              size: 10,
                              color: const Color(0xFF00A8DD),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : IconsActivity(type: activity.actiIdTipoGestion),
          ],
        ),
      ),
      onTap: callbackOnTap,
    );
  }

  /// Obtiene el prefijo del contacto según el tipo de actividad y dirección
  String _getContactPrefix(Activity activity) {
    final contacto = activity.contactoDesc ?? '';
    if (contacto.isEmpty) return '';

    // Para emails, usar emlsIdTipoMailfolders
    if (activity.actiIdTipoGestion == '07') {
      return activity.emlsIdTipoMailfolders == '02'
          ? 'A: $contacto'
          : 'De: $contacto';
    }

    // Para otros tipos de actividades, usar actiIdTipoRegistro
    // '01' = Manual/Saliente, '02' = Entrante/Recibido
    if (activity.actiIdTipoRegistro == '02') {
      return 'De: $contacto';
    } else {
      return 'A: $contacto';
    }
  }
}

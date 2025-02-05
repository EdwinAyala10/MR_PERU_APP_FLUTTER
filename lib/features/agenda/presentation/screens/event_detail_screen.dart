import '../providers/providers.dart';
import '../../../shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, 
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider(eventId));

    final event = eventState.event;

    if (eventState.isLoading) {
      return const FullScreenLoader();
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                alignment: Alignment.center,
                child: const Text(
                  'No se encontro información del evento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ))
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de evento', style: TextStyle(
          fontWeight: FontWeight.w500
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: event.evntIdTipoRegistro == '01' ? () {
              context.push('/event/${event.id}');
            } : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              ContainerCustom(
                label: 'Asunto',
                text: event.evntAsunto,
              ),
              ContainerCustom(
                label: 'Tipo de gestión',
                text: event.evntNombreTipoGestion ?? '',
              ),
              ContainerCustom(
                label: 'Empresa',
                text: '${event.evntRazon}',
              ),
              ContainerCustom(
                label: 'Local',
                text: '${event.evntLocalNombre}',
              ),
              ContainerCustom(
                label: 'Todo el dia',
                text: event.todoDia.toString(),
              ),
              ContainerCustom(
                label: 'Fecha',
                text:  DateFormat('dd-MM-yyyy').format(
                        event.evntFechaInicioEvento ?? DateTime.now()),
              ),
              event.todoDia == "0" 
              ? ContainerCustom(
                label: 'Hora inicio',
                text: DateFormat('hh:mm a').format(
                              event.evntHoraInicioEvento != null
                                  ? DateFormat('HH:mm:ss').parse(
                                      event.evntHoraInicioEvento ?? '')
                                  : DateTime.now()),
              ) :  const SizedBox(),
              event.todoDia == "0" 
              ? ContainerCustom(
                label: 'Hora fin',
                text: DateFormat('hh:mm a').format(
                              event.evntHoraFinEvento != null
                                  ? DateFormat('HH:mm:ss').parse(
                                      event.evntHoraFinEvento ?? '')
                                  : DateTime.now()),
              ) : const SizedBox(),
              ContainerCustom(
                label: 'Recordatorio de cita',
                text: event.evntNombreRecordatorio ?? '',
              ),

              if (event.arraycontacto != null &&
                event.arraycontacto!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric( horizontal: 10 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contactos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          event.arraycontacto!.map((arr) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            arr.contactoDesc ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (event.arrayresponsable != null &&
                event.arrayresponsable!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric( horizontal: 10 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          event.arrayresponsable!.map((arr) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            arr.userreportName ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 10,
              ),

              ContainerCustom(
                label: 'Oportunidad',
                text: event.evntNombreOportunidad ?? '',
              ),


              
              ContainerCustom(
                label: 'Responsable',
                text: event.evntNombreUsuarioResponsable ?? '',
              ),

              ContainerCustom(
                label: 'Comentario',
                text: event.evntComentario ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContainerCustom extends StatelessWidget {
  String label;
  String text;
  IconData? icon;
  Function()? callbackIcon;
  Widget? icon2;
  Function()? callbackIcon2;
  ContainerCustom(
      {super.key,
      required this.label,
      required this.text,
      this.icon,
      this.callbackIcon,
      this.icon2,
      this.callbackIcon2});

  @override
  Widget build(BuildContext context) {
    if (text == "") {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 247, 245, 245),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  maxLines: 10,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Expanded(child: SizedBox()),
                icon2 != null
                    ? IconButton(
                        icon: icon2!,
                        iconSize: 20, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon2,
                      )
                    : const SizedBox(),
                icon != null
                    ? IconButton(
                        icon: Icon(icon),
                        iconSize: 30, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

String agregarPrefijoPeru(String numero) {
  // Verificar si el número ya tiene el prefijo de país "+51"
  if (!numero.startsWith('+51')) {
    // Si no tiene el prefijo, agregarlo al principio
    return '+51$numero';
  }
  // Si ya tiene el prefijo, devolver el número sin cambios
  return numero;
}

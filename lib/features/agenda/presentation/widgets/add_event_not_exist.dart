import 'dart:collection';

import '../../domain/domain.dart';

LinkedHashMap<DateTime, List<Event>> addEventIfNotExist(
    LinkedHashMap<DateTime, List<Event>> linkedEvents, Event evento) {
  // Obtener la fecha del evento
  DateTime? fechaEvento = evento.evntFechaInicioEvento;

  // Verificar si la fecha ya está presente en el LinkedHashMap
  if (linkedEvents.containsKey(fechaEvento)) {
    // La fecha ya está presente, ahora verificamos si el evento ya existe en la lista
    List<Event> eventosEnFecha = linkedEvents[fechaEvento]!;
    bool eventoExistente = eventosEnFecha.any((e) => e.id == evento.id);
    if (!eventoExistente) {
      // El evento no existe en la lista, agregamos el evento a la lista de eventos
      eventosEnFecha.add(evento);
    }
  } else {
    // La fecha no está presente, agregamos una nueva entrada al LinkedHashMap
    linkedEvents[fechaEvento!] = [evento];
  }

  return linkedEvents;
}

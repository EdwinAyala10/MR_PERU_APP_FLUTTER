
import 'dart:collection';

import '../../domain/domain.dart';

LinkedHashMap<DateTime, List<Event>> replaceEventExist(
    LinkedHashMap<DateTime, List<Event>> linkedEvents, Event evento) {
  // Crear una copia del LinkedHashMap original
  LinkedHashMap<DateTime, List<Event>> nuevoLinkedEvents =
      LinkedHashMap<DateTime, List<Event>>.from(linkedEvents);

  // Obtener la fecha del evento
  DateTime fechaEvento = evento.evntFechaInicioEvento!;

  // Verificar si la fecha ya está presente en el LinkedHashMap
  if (nuevoLinkedEvents.containsKey(fechaEvento)) {
    // La fecha ya está presente, ahora buscamos el evento existente por su ID
    List<Event> eventosEnFecha = nuevoLinkedEvents[fechaEvento]!;
    for (int i = 0; i < eventosEnFecha.length; i++) {
      if (eventosEnFecha[i].id == evento.id) {
        // Reemplazar el evento existente por el nuevo evento
        eventosEnFecha[i] = evento;
        // Devolver el LinkedHashMap actualizado
        return nuevoLinkedEvents;
      }
    }
  }

  // Si la fecha no está presente o no se encuentra el evento, simplemente agregamos el nuevo evento
  nuevoLinkedEvents.putIfAbsent(fechaEvento, () => [evento]);

  // Devolver el LinkedHashMap actualizado
  return nuevoLinkedEvents;
}

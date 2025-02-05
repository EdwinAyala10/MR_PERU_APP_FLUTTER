import 'dart:collection';

import '../../domain/domain.dart';

bool eventItExist(LinkedHashMap<DateTime, List<Event>> linkedEvents, String eventId) {
  // Iterar sobre las claves (fechas) del mapa
  for (final eventsList in linkedEvents.values) {
    // Iterar sobre la lista de eventos para la fecha actual
    for (final event in eventsList) {
      // Verificar si el id del evento coincide
      if (event.id == eventId) {
        // El evento ya existe en la lista
        return true;
      }
    }
  }
  // El evento no existe en la lista
  return false;
}
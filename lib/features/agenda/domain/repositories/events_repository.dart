import 'dart:collection';

import '../domain.dart';

abstract class EventsRepository {
  Future<LinkedHashMap<DateTime, List<Event>>> getEvents(String idUsuario);
  Future<List<Event>> getEventsList(String idUsuario);
  Future<List<Event>> getEventsListByObjetive(String id);

  Future<List<Event>> getEventsListByRuc(String ruc);
  Future<Event> getEventById(String id);

  Future<EventResponse> createUpdateEvent(Map<dynamic, dynamic> eventLike);
}

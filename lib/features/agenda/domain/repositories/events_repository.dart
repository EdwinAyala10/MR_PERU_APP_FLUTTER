
import 'dart:collection';

import '../domain.dart';

abstract class EventsRepository {

  Future<LinkedHashMap<DateTime, List<Event>>> getEvents();
  Future<List<Event>> getEventsList();
  Future<List<Event>> getEventsListByRuc(String ruc);
  Future<Event> getEventById(String id);

  Future<EventResponse> createUpdateEvent( Map<dynamic,dynamic> eventLike );
}


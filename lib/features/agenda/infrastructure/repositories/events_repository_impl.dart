import 'dart:collection';

import '../../domain/domain.dart';

class EventsRepositoryImpl extends EventsRepository {

  final EventsDatasource datasource;

  EventsRepositoryImpl(this.datasource);

  @override
  Future<EventResponse> createUpdateEvent(Map<dynamic, dynamic> eventLike) {
    return datasource.createUpdateEvent(eventLike);
  }

  @override
  Future<Event> getEventById(String id) {
    return datasource.getEventById(id);
  }

  @override
  Future<LinkedHashMap<DateTime, List<Event>>> getEvents(String idUsuario) {
    return datasource.getEvents(idUsuario);
  }

  @override
  Future<List<Event>> getEventsList(String idUsuario) {
    return datasource.getEventsList(idUsuario);
  }

  @override
  Future<List<Event>> getEventsListByRuc(String ruc) {
    return datasource.getEventsListByRuc(ruc);
  }
  
  @override
  Future<List<Event>> getEventsListByObjetive(String id) {
    return datasource.getEventsListByObjetive(id);
  }


}
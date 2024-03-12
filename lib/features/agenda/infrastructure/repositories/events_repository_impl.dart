import 'dart:collection';

import 'package:crm_app/features/agenda/domain/domain.dart';

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
  Future<LinkedHashMap<DateTime, List<Event>>> getEvents() {
    return datasource.getEvents();
  }

}
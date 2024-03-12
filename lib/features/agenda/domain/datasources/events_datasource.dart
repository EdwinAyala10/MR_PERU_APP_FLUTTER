import 'dart:collection';

import 'package:crm_app/features/agenda/domain/domain.dart';

abstract class EventsDatasource {

  Future<LinkedHashMap<DateTime, List<Event>>> getEvents();
  Future<Event> getEventById(String id);

  Future<EventResponse> createUpdateEvent( Map<dynamic,dynamic> eventLike );

}


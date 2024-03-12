import 'dart:collection';

import 'package:crm_app/features/agenda/infrastructure/mappers/event_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/agenda/domain/domain.dart';

import '../errors/event_errors.dart';
import '../mappers/event_mapper.dart';

class EventsDatasourceImpl extends EventsDatasource {
  late final Dio dio;
  final String accessToken;

  EventsDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<EventResponse> createUpdateEvent(
      Map<dynamic, dynamic> eventLike) async {
    try {
      final String? id = eventLike['EVNT_ID_EVENTO'];
      final String method = 'POST';
      final String url = '/evento/create-evento';

      print('eventLike:${eventLike}');

      final response = await dio.request(url,
          data: eventLike, options: Options(method: method));

      print('RESP:${response}');

      final EventResponse eventResponse =
          EventResponseMapper.jsonToEntity(response.data);

      print('eventResponse: ${eventResponse.message}');

      if (eventResponse.status == true) {
        eventResponse.event = EventMapper.jsonToEntity(response.data['data']);
      }

      return eventResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw EventNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Event> getEventById(String id) async {
    try {
      final response = await dio.get('/evento/listar-evento-by-id/$id');
      final Event event = EventMapper.jsonToEntity(response.data['data']);

      return event;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw EventNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<LinkedHashMap<DateTime, List<Event>>> getEvents() async {
    final response = await dio.post('/evento/listar-evento-by-id-tipo-gestion');
    //final List<Event> events = [];
    LinkedHashMap<DateTime, List<Event>> linkedEvents = LinkedHashMap();

    print('RESP LIST:${response}');

    for (final event in response.data['data'] ?? []) {
      final eventModal = EventMapper.jsonToEntity(event) as Event;
      print('EVENT: ${eventModal.evntFechaInicioEvento}');
      DateTime fechaInicio = eventModal.evntFechaInicioEvento ?? DateTime.now();

      if (linkedEvents.containsKey(fechaInicio)) {
        linkedEvents[fechaInicio]!.add(eventModal);
      } else {
        linkedEvents[fechaInicio] = [eventModal];
      }
      //events.add(EventMapper.jsonToEntity(event));
      //linkedEvents.addAll(other)
    }

    return linkedEvents;
  }
}

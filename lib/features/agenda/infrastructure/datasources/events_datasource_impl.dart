import 'dart:collection';

import '../mappers/event_response_mapper.dart';
import 'package:dio/dio.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

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
      //final String url = '/evento/create-evento';
      final String url = (id == null)
          ? '/evento/create-evento'
          : '/evento/edit-evento';

      if (id == null) {
        eventLike.remove('EVNT_ID_EVENTO');
      }
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
      print('ID: ${id}');
      final response = await dio.get('/evento/listar-evento-by-id/$id');
      print('RES GETEVENTBYID: ${response}');
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
    try {
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
    } on DioException catch (e) {
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Event>> getEventsList() async {
    try {
      final response = await dio.post('/evento/listar-evento-by-id-tipo-gestion');
      final List<Event> events = [];
      for (final event in response.data['data'] ?? []) {
        events.add(EventMapper.jsonToEntity(event));
      }

      return events;
    } on DioException catch (e) {
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Event>> getEventsListByRuc(String ruc) async {
    final data = {
      "RUC": ruc,
    };

    final response = await dio.post('/evento/listar-evento-by-ruc', data: data);
    final List<Event> events = [];
    for (final event in response.data['data'] ?? []) {
      events.add(EventMapper.jsonToEntity(event));
    }

    return events;
  }
}

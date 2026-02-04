import 'package:crm_app/features/route-planner/domain/entities/coordenada.dart';
import 'package:crm_app/features/route-planner/domain/entities/distance_filter.dart';
import 'package:crm_app/features/route-planner/domain/entities/event_planner_response.dart';
import 'package:crm_app/features/route-planner/domain/entities/validate_event_planner_response.dart';
import 'package:crm_app/features/route-planner/domain/entities/validate_horario_trabajo_response.dart';
import 'package:crm_app/features/route-planner/infrastructure/errors/route_planner_errors.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/coordenada_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/distance_filter_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/event_planner_response_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/validar_horario_trabajo_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/validate_event_planner_response_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/validate_horario_trabajo_response_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/validate_variable_response_mapper.dart';
import 'package:dio/dio.dart';

import '../infrastructure.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

class RoutePlannerDatasourceImpl extends RoutePlannerDatasource {
  late final Dio dio;
  final String accessToken;

  RoutePlannerDatasourceImpl({required this.accessToken})
      : dio = Dio(
          BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );
  @override
  Future<List<CompanyLocalRoutePlanner>> getCompanyLocals(
      {int limit = 10,
      int offset = 0,
      String search = '',
      List<FilterOption> filters = const [],
      double? latMin,
      double? latMax,
      double? lngMin,
      double? lngMax}) async {
    // El endpoint espera form-data; alineamos con el cURL proporcionado
    final Map<String, dynamic> data = {
      'SEARCH': search,
      'OFFSET': offset,
      'TOP': limit,
      'RUC': '',
      'TIPOCLIENTE': '',
      'ESTADO_CRM': '',
      'CALIFICACION': '',
      'ID_USUARIO_RESPONSABLE': '',
      'ULTIMAS_VISITAS': '',
      'CODIGO_POSTAL': '',
      'DISTRITO': '',
      'ID_RUBRO': '',
      'RAZON_COMERCIAL': '',
      'ESTADO': '',
    };

    // Mapear filtros (excepto distancia) a los campos que el backend espera
    if (filters.isNotEmpty) {
      for (var filter in filters) {
        if (filter.type != 'DISTANCIA') {
          data[filter.type] = filter.id;
        }
      }
    }

    // Bounding box si está disponible
    data['LAT_MIN'] = latMin?.toString() ?? '';
    data['LAT_MAX'] = latMax?.toString() ?? '';
    data['LNG_MIN'] = lngMin?.toString() ?? '';
    data['LNG_MAX'] = lngMax?.toString() ?? '';

    final response = await dio.post(
      '/cliente/listar-clientes-local',
      data: FormData.fromMap(data),
    );

    final List<CompanyLocalRoutePlanner> locales = [];

    for (final local in response.data['data'] ?? []) {
      locales.add(CompanyLocalRoutePlannerMapper.jsonToEntity(local));
    }

    return locales;
  }

  @override
  Future<List<FilterActivity>> getFilterActivities() async {
    final response = await dio.get('/cliente/listar-filtro-actividad');

    final List<FilterActivity> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterActivityMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterResponsable>> getFilterResponsable(
      {String search = ''}) async {
    final response = await dio
        .get('/user/listar-usuarios-by-tipo', data: {'SEARCH': search});

    final List<FilterResponsable> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterResponsableMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterCodigoPostal>> getFilterCodigoPostal(
      {String search = ''}) async {
    final response = await dio
        .get('/cliente/listar-codigo-postal', data: {'SEARCH': search});

    final List<FilterCodigoPostal> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterCodigoPostalMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterDistrito>> getFilterDistrito({String search = ''}) async {
    final response =
        await dio.get('/cliente/listar-distrito', data: {'SEARCH': search});

    final List<FilterDistrito> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterDistritoMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterRucRazonSocial>> getFilterRucRazonSocial(
      {String search = ''}) async {
    final response = await dio.post(
        '/cliente/listar-clientes-by-ruc-tipo-est-Cal',
        data: {'SEARCH': search});

    final List<FilterRucRazonSocial> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterRucRazonSocialMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<EventPlannerResponse> createEventPlanner(
      Map<dynamic, dynamic> eventLike) async {
    try {
      const String method = 'POST';
      const String url = '/evento/crear-planificador-ruta';

      final response = await dio.request(url,
          data: eventLike, options: Options(method: method));

      final EventPlannerResponse eventResponse =
          EventPlannerResponseMapper.jsonToEntity(response.data);

      return eventResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw RoutePlannerNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<FilterHorarioTrabajo>> getFilterHorarioTrabajo(
      {String search = ''}) async {
    final response = await dio.post('/horario-trabajo/listar-horario-trabajo',
        data: {'SEARCH': search});

    final List<FilterHorarioTrabajo> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterHorarioTrabajoMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<ValidateEventPlannerResponse> validateEventPlanner(
      Map<dynamic, dynamic> event) async {
    try {
      const String method = 'POST';
      const String url = '/evento/validar-planificador-evento';

      final response =
          await dio.request(url, data: event, options: Options(method: method));

      final ValidateEventPlannerResponse eventResponse =
          ValidateEventPlannerResponseMapper.jsonToEntity(response.data);

      print('STATUS: ${eventResponse.status}');

      if (eventResponse.status == true) {
        eventResponse.data =
            ValidateVariableResponseMapper.jsonToEntity(response.data['data']);
      }

      return eventResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw RoutePlannerNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Coordenada> getCoordenadas() async {
    try {
      final response =
          await dio.get('/planificador/obtener-coordenada-punto-partida');
      final Coordenada coordenada =
          CoordenadaMapper.jsonToEntity(response.data['data']);

      return coordenada;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw RoutePlannerNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<DistanceFilter>> getDistanceFilters() async {
    final response = await dio.get('/cliente/listar-distancia');

    final List<DistanceFilter> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(DistanceFilterMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<ValidateHorarioTrabajoResponse> getHorarioTrabajo() async {
    final response = await dio.post('/horario-trabajo/validar-horario-trabajo');

    ValidateHorarioTrabajoResponse result =
        ValidateHorarioTrabajoResponseMapper.jsonToEntity(response.data);

    if (result.status) {
      result.data =
          ValidarHorarioTrabajoMapper.jsonToEntity(response.data['data']);
    }

    return result;
  }
}

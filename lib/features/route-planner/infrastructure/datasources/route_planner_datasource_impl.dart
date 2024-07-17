import 'package:dio/dio.dart';

import '../infrastructure.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

class RoutePlannerDatasourceImpl extends RoutePlannerDatasource {
  late final Dio dio;
  final String accessToken;

  RoutePlannerDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<List<CompanyLocalRoutePlanner>> getCompanyLocals({ 
    int limit = 10, 
    int offset = 0, 
    String search = '', 
    List<FilterOption> filters = const []
  }) async {

    var data = {
      'SEARCH': search,
      'OFFSET': offset,
      'TOP': limit,
    };

    if (filters.isNotEmpty) {
      for (var filter in filters) {
        data[filter.type] = filter.id;
      }
    }

    final response =
        await dio.post('/cliente/listar-clientes-local', data: data);


    final List<CompanyLocalRoutePlanner> locales = [];

    for (final local in response.data['data'] ?? []) {
      locales.add(CompanyLocalRoutePlannerMapper.jsonToEntity(local));
    }

    return locales;
  }

  @override
  Future<List<FilterActivity>> getFilterActivities() async {
    final response =
      await dio.get('/cliente/listar-filtro-actividad');

    final List<FilterActivity> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterActivityMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterResponsable>> getFilterResponsable({ String search = '' }) async {
    final response =
      await dio.get('/user/listar-usuarios-by-tipo', data: {
        'SEARCH': search
      });

    final List<FilterResponsable> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterResposanbleMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterCodigoPostal>> getFilterCodigoPostal({ String search = '' }) async {
    final response =
      await dio.get('/cliente/listar-codigo-postal', data: {
        'SEARCH': search
      });

    final List<FilterCodigoPostal> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterCodigoPostalMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterDistrito>> getFilterDistrito({ String search = '' }) async {
    final response =
      await dio.get('/cliente/listar-distrito', data: {
        'SEARCH': search
      });

    final List<FilterDistrito> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterDistritoMapper.jsonToEntity(filter));
    }

    return filters;
  }

  @override
  Future<List<FilterRucRazonSocial>> getFilterRucRazonSocial({ String search = '' }) async {
    final response =
      await dio.post('/cliente/listar-clientes-by-ruc-tipo-est-Cal', data: {
        'SEARCH': search
      });

    final List<FilterRucRazonSocial> filters = [];

    for (final filter in response.data['data'] ?? []) {
      filters.add(FilterRucRazonSocialMapper.jsonToEntity(filter));
    }

    return filters;
  }

  
}
import '../../domain/entities/check_in_by_ruc_local_response.dart';
import '../infrastructure.dart';
import '../mappers/check_in_by_ruc_local_mapper.dart';
import '../mappers/check_in_by_ruc_local_response.dart_mapper.dart';
import '../mappers/company_response_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/distance_filter_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/filter_activity_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/filter_distrito_mapper.dart';
import 'package:crm_app/features/route-planner/infrastructure/mappers/filter_responsable_mapper.dart';
import '../mappers/filter_departamento_mapper.dart';
import '../mappers/filter_estado_mapper.dart';
import '../mappers/filter_provincia_mapper.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_option.dart';
import 'package:crm_app/features/route-planner/domain/entities/distance_filter.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_activity.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_responsable.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_distrito.dart';
import 'package:dio/dio.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

class CompaniesDatasourceImpl extends CompaniesDatasource {
  late final Dio dio;
  final String accessToken;

  CompaniesDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<CompanyResponse> createUpdateCompany(
      Map<dynamic, dynamic> companyLike) async {
    try {
      final String? rucId = companyLike['RUCID'];
      const String method = 'POST';
      final String url = (rucId == null)
          ? '/cliente/create-cliente'
          : '/cliente/update-cliente';

      //companyLike.remove('rucId');

      //companyLike['ID_USUARIO_ACTUALIZACION'] = companyLike['ID_USUARIO_REGISTRO'];

      final response = await dio.request(url,
          data: companyLike, options: Options(method: method));

      final CompanyResponse companyResponse =
          CompanyResponseMapper.jsonToEntity(response.data);

      if (companyResponse.status == true) {
        companyResponse.company =
            CompanyMapper.jsonToEntity(response.data['data']);
      }

      return companyResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw CompanyNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Company> getCompanyById(String rucId, String userId) async {
    try {
      final response = await dio.get('/cliente/cliente-by-ruc/$rucId/$userId');
      final Company company = CompanyMapper.jsonToEntity(response.data['data']);

      if (rucId != 'new') {
        company.rucId = company.ruc;
        company.localTipo = '2';
        company.localDireccion = '-';
      }
      return company;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw CompanyNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Company>> getCompanies({
    int limit = 10,
    int offset = 0,
    String search = '',
    List<FilterOption> filters = const [],
    double? latMin,
    double? latMax,
    double? lngMin,
    double? lngMax,
  }) async {
    // Usar FormData para enviar como form-data (multipart/form-data)
    final formData = FormData.fromMap({
      'SEARCH': search,
      'OFFSET': offset.toString(),
      'TOP': limit.toString(),
    });

    if (filters.isNotEmpty) {
      for (var filter in filters) {
        if (filter.type != 'Distancia') {
          formData.fields.add(MapEntry(filter.type, filter.id));
        }
      }
    }

    // Agregar parámetros de bounding box si están disponibles
    if (latMin != null)
      formData.fields.add(MapEntry('LAT_MIN', latMin.toString()));
    if (latMax != null)
      formData.fields.add(MapEntry('LAT_MAX', latMax.toString()));
    if (lngMin != null)
      formData.fields.add(MapEntry('LNG_MIN', lngMin.toString()));
    if (lngMax != null)
      formData.fields.add(MapEntry('LNG_MAX', lngMax.toString()));

    final response = await dio.post(
      '/cliente/listar-clientes-by-ruc-tipo-est-Cal',
      data: formData,
    );

    final List<Company> companies = [];

    for (final company in response.data['data'] ?? []) {
      companies.add(CompanyMapper.jsonToEntity(company));
    }

    return companies;
  }

  @override
  Future<List<Company>> searchCompaniesActive(String dni, String query) async {
    final data = {
      "SEARCH": query,
    };

    final response = await dio.get('/cliente/clientes-activo/$dni', data: data);
    final List<Company> companies = [];
    for (final company in response.data['data'] ?? []) {
      companies.add(CompanyMapper.jsonToEntity(company));
    }

    return companies;
  }

  @override
  Future<CompanyCheckInResponse> createCompanyCheckIn(
      Map<dynamic, dynamic> companyCheckInLike) async {
    try {
      const String method = 'POST';
      const String url = '/cliente-check/create-cliente-check';

      final response = await dio.request(url,
          data: companyCheckInLike, options: Options(method: method));

      final CompanyCheckInResponse companyCheckInResponse =
          CompanyCheckInResponseMapper.jsonToEntity(response.data);

      return companyCheckInResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw CompanyNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<CompanyLocalResponse> createUpdateCompanyLocal(
      Map<dynamic, dynamic> companyLocalLike) async {
    try {
      final String? id = companyLocalLike['LOCAL_CODIGO'];
      const String method = 'POST';
      final String url = (id == null)
          ? '/cliente/create-cliente-locales'
          : '/cliente/actualizar-cliente-locales';

      if (id == null) {
        companyLocalLike.remove('LOCAL_CODIGO');
      }

      final response = await dio.request(url,
          data: companyLocalLike, options: Options(method: method));

      final CompanyLocalResponse companyLocalResponse =
          CompanyLocalResponseMapper.jsonToEntity(response.data);

      if (companyLocalResponse.status == true) {
        companyLocalResponse.companyLocal =
            CompanyLocalMapper.jsonToEntity(response.data['data']);
      }

      return companyLocalResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw CompanyNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<CompanyLocal> getLocalById(String rucId, String localId) async {
    try {
      final response = await dio.get('/cliente/cliente-locales-by-local',
          data: {'RUC': rucId, 'LOCAL_CODIGO': localId});
      final CompanyLocal companyLocal =
          CompanyLocalMapper.jsonToEntity(response.data['data']);

      return companyLocal;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw CompanyNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<CompanyLocal>> getCompanyLocales(String ruc) async {
    final response = await dio.get('/cliente/cliente-locales-by-ruc/$ruc');

    final List<CompanyLocal> companyLocales = [];

    for (final company in response.data['data'] ?? []) {
      companyLocales.add(CompanyLocalMapper.jsonToEntity(company));
    }

    return companyLocales;
  }

  @override
  Future<List<CompanyLocal>> searchCompanyLocalesActive(
      String ruc, String query) async {
    final data = {
      "SEARCH": query,
    };

    final response =
        await dio.get('/cliente/cliente-locales-by-ruc/$ruc', data: data);
    final List<CompanyLocal> companyLocales = [];
    for (final companyLocal in response.data['data'] ?? []) {
      companyLocales.add(CompanyLocalMapper.jsonToEntity(companyLocal));
    }

    return companyLocales;
  }

  @override
  Future<CheckInByRucLocalResponse> getCheckInByRucLocal(
      String ruc, String user) async {
    try {
      final data = {"RUC": ruc, "ID_USUARIO_RESPONSABLE": user};

      final response = await dio
          .post('/cliente-check/listar-check-by-ruc-local', data: data);
      final CheckInByRucLocalResponse checkInByRucLocalResponse =
          CheckInByRucLocalResponseMapper.jsonToEntity(response.data);

      if (checkInByRucLocalResponse.status == true) {
        //checkInByRucLocalResponse.checkInByRucLocal =
        //CheckInByRucLocalMapper.jsonToEntity(response.data['data']);
      }

      return checkInByRucLocalResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw CompanyNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<FilterResponsable>> getFilterResponsable(
      {String search = ''}) async {
    final response =
        await dio.get('/user/listar-usuarios-by-tipo?SEARCH=$search');
    final List<FilterResponsable> responsables = [];
    for (final responsable in response.data['data'] ?? []) {
      responsables.add(FilterResponsableMapper.jsonToEntity(responsable));
    }
    return responsables;
  }

  @override
  Future<List<FilterActivity>> getFilterActividad() async {
    final response = await dio.get('/cliente/listar-filtro-actividad');
    final List<FilterActivity> list = [];
    for (final item in response.data['data'] ?? []) {
      list.add(FilterActivityMapper.jsonToEntity(item));
    }
    return list;
  }

  @override
  Future<List<FilterDepartamento>> getFilterDepartamento(
      {String search = ''}) async {
    final response =
        await dio.get('/cliente/listar-departamento?SEARCH=$search');
    final List<FilterDepartamento> list = [];
    for (final item in response.data['data'] ?? []) {
      list.add(FilterDepartamentoMapper.jsonToEntity(item));
    }
    return list;
  }

  @override
  Future<List<FilterProvincia>> getFilterProvincia(
      {String search = '', String departamento = ''}) async {
    final response = await dio.get(
        '/cliente/listar-provincia-by-departamento?SEARCH=$search&DEPARTAMENTO=$departamento');
    final List<FilterProvincia> list = [];
    for (final item in response.data['data'] ?? []) {
      list.add(FilterProvinciaMapper.jsonToEntity(item));
    }
    return list;
  }

  @override
  Future<List<FilterDistrito>> getFilterDistrito(
      {String search = '', String provincia = ''}) async {
    final response = await dio.get(
        '/cliente/listar-distrito-by-provincia?SEARCH=$search&PROVINCIA=$provincia');
    final List<FilterDistrito> list = [];
    for (final item in response.data['data'] ?? []) {
      list.add(FilterDistritoMapper.jsonToEntity(item));
    }
    return list;
  }

  @override
  Future<List<FilterEstado>> getFilterEstado() async {
    final response = await dio.get('/cliente/listar-estado');
    final List<FilterEstado> list = [];
    for (final item in response.data['data'] ?? []) {
      list.add(FilterEstadoMapper.jsonToEntity(item));
    }
    return list;
  }

  @override
  Future<List<DistanceFilter>> getDistanceFilters() async {
    final response = await dio.get('/cliente/listar-distancia');
    final List<DistanceFilter> list = [];
    for (final item in response.data['data'] ?? []) {
      list.add(DistanceFilterMapper.jsonToEntity(item));
    }
    // Ordenar: Todos (valor "0") primero, luego por valor absoluto ascendente (5, 10, 20...)
    list.sort((a, b) {
      // "Todos" siempre va primero
      if (a.valor == "0") return -1;
      if (b.valor == "0") return 1;

      // Convertir a números y comparar por valor absoluto (para manejar negativos: -5, -10, -20)
      final aValue = int.tryParse(a.valor) ?? 0;
      final bValue = int.tryParse(b.valor) ?? 0;
      return aValue.abs().compareTo(bValue.abs());
    });
    return list;
  }

  @override
  Future<Map<String, Map<String, String?>>> getCompanyCoordinates({
    int limit = 10,
    int offset = 0,
    String search = '',
    List<FilterOption> filters = const [],
  }) async {
    try {
      final data = {
        'SEARCH': search,
        'OFFSET': offset,
        'TOP': limit,
      };

      if (filters.isNotEmpty) {
        for (var filter in filters) {
          if (filter.type != 'DISTANCIA') {
            data[filter.type] = filter.id;
          }
        }
      }

      final response =
          await dio.post('/cliente/listar-clientes-local', data: data);

      final Map<String, Map<String, String?>> coordinatesMap = {};

      for (final local in response.data['data'] ?? []) {
        final ruc = local['RUC']?.toString() ?? '';
        if (ruc.isNotEmpty) {
          final latitud = local['LOCAL_COORDENADAS_LATITUD']?.toString().trim();
          final longitud =
              local['LOCAL_COORDENADAS_LONGITUD']?.toString().trim();

          // Solo agregar si tiene coordenadas válidas
          if (latitud != null &&
              latitud.isNotEmpty &&
              longitud != null &&
              longitud.isNotEmpty) {
            // Si ya existe el RUC, mantener el primero (o podrías actualizar si prefieres el último)
            if (!coordinatesMap.containsKey(ruc)) {
              coordinatesMap[ruc] = {
                'latitud': latitud,
                'longitud': longitud,
              };
            }
          }
        }
      }

      return coordinatesMap;
    } catch (e) {
      // Si hay error, retornar mapa vacío para no romper el flujo
      return {};
    }
  }
}

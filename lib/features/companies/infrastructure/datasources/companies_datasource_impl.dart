import '../../domain/entities/check_in_by_ruc_local_response.dart';
import '../infrastructure.dart';
import '../mappers/check_in_by_ruc_local_mapper.dart';
import '../mappers/check_in_by_ruc_local_response.dart_mapper.dart';
import '../mappers/company_response_mapper.dart';
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
      final Company company= CompanyMapper.jsonToEntity(response.data['data']);

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
  Future<List<Company>> getCompanies({ int limit = 10, int offset = 0, String search = '' }) async {
    final response =
        await dio.post('/cliente/listar-clientes-by-ruc-tipo-est-Cal', data: {
          'SEARCH': search,
          'OFFSET': offset,
          'TOP': limit,
        });

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

      /*if (companyCheckInResponse.status == true) {
        companyCheckInResponse.companyCheckIn =
            CompanyCheckInMapper.jsonToEntity(response.data['data']);
      }*/

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
      final response = await dio.get('/cliente/cliente-locales-by-local', data: {
        'RUC': rucId,
        'LOCAL_CODIGO': localId
      });
      final CompanyLocal companyLocal = CompanyLocalMapper.jsonToEntity(response.data['data']);

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
    final response =
        await dio.get('/cliente/cliente-locales-by-ruc/$ruc');
    
    final List<CompanyLocal> companyLocales = [];

    for (final company in response.data['data'] ?? []) {
      companyLocales.add(CompanyLocalMapper.jsonToEntity(company));
    }

    return companyLocales;
  }

  @override
  Future<List<CompanyLocal>> searchCompanyLocalesActive(String ruc, String query) async {
    final data = {
      "SEARCH": query,
    };

    final response = await dio.get('/cliente/cliente-locales-by-ruc/$ruc', data: data);
    final List<CompanyLocal> companyLocales = [];
    for (final companyLocal in response.data['data'] ?? []) {
      companyLocales.add(CompanyLocalMapper.jsonToEntity(companyLocal));
    }

    return companyLocales;
  }

  @override
  Future<CheckInByRucLocalResponse> getCheckInByRucLocal(String ruc, String user) async {
    try {

      final data = {
        "RUC": ruc,
        "ID_USUARIO_RESPONSABLE": user
      };

      final response = await dio.post('/cliente-check/listar-check-by-ruc-local', data: data );
      final CheckInByRucLocalResponse checkInByRucLocalResponse = CheckInByRucLocalResponseMapper.jsonToEntity(response.data);

      if (checkInByRucLocalResponse.status == true) {
        checkInByRucLocalResponse.checkInByRucLocal =
            CheckInByRucLocalMapper.jsonToEntity(response.data['data']);
      }

      return checkInByRucLocalResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw CompanyNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }

  }


}

import 'package:crm_app/features/companies/infrastructure/mappers/company_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

import '../errors/company_errors.dart';
import '../mappers/company_mapper.dart';

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

      print('URL CREATE COMPANY: ${url}');
      print('RUC ID: ${rucId}');
      print('companyLike: ${companyLike}');

      final response = await dio.request(url,
          data: companyLike, options: Options(method: method));

      print('RESP companies: ${response}');

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
  Future<Company> getCompanyById(String rucId) async {
    try {
      final response = await dio.get('/cliente/cliente-by-ruc/$rucId');
      final Company company = CompanyMapper.jsonToEntity(response.data['data']);

      if (rucId != 'new') {
        company.rucId = company.ruc;
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
  Future<List<Company>> getCompanies() async {
    final response =
        await dio.post('/cliente/listar-clientes-by-ruc-tipo-est-Cal');
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
}

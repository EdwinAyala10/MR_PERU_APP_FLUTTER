import 'dart:ffi';

import 'package:crm_app/features/companies/infrastructure/mappers/company_get_mapper.dart';
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
  Future<Bool> createUpdateCompany(Map<String, dynamic> companyLike) async {
    try {
      print('ID CREATE UPDATE: ${companyLike['id']}');

      final String? id = companyLike['id'];
      final String method = (id == null) ? 'POST' : 'POST';
      final String url =
          (id == null) ? '/cliente/create-cliente' : '/cliente/update-cliente';

      companyLike.remove('id');

      final response = await dio.request(url,
        data: companyLike, options: Options(method: method));

      //final company = CompanyMapper.jsonToEntity(response.data);
      //return company;
      return response.data;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Company> getCompanyById(String ruc) async {
    try {
      final response = await dio.get('/cliente/cliente-by-ruc/$ruc');
      final company = CompanyGetMapper.jsonToEntity(response.data['data']);
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
}

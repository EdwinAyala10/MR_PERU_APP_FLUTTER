import 'package:crm_app/features/opportunities/infrastructure/mappers/opportunity_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';

import '../errors/opportunity_errors.dart';
import '../mappers/opportunity_mapper.dart';

class OpportunitiesDatasourceImpl extends OpportunitiesDatasource {
  late final Dio dio;
  final String accessToken;

  OpportunitiesDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<OpportunityResponse> createUpdateOpportunity(
      Map<dynamic, dynamic> opportunityLike) async {

        print('OPPORTUNITY: ${opportunityLike}');
    try {
      final String? id = opportunityLike['OPRT_ID_OPORTUNIDAD'];
      final String method = 'POST';
      final String url = '/oportunidad/create-oportunidad';

      final response = await dio.request(url,
          data: opportunityLike, options: Options(method: method));

      print('RESPONSE: ${response}');

      final OpportunityResponse opportunityResponse =
          OpportunityResponseMapper.jsonToEntity(response.data);

      if (opportunityResponse.status == true) {
        opportunityResponse.opportunity =
            OpportunityMapper.jsonToEntity(response.data['data']);
      }

      return opportunityResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw OpportunityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Opportunity> getOpportunityById(String id) async {
    try {
      final response = await dio.get('/oportunidad/listar-oportunidad-by-id/$id');
      final Opportunity opportunity = OpportunityMapper.jsonToEntity(response.data['data']);

      return opportunity;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw OpportunityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Opportunity>> getOpportunities() async {
    final response =
        await dio.post('/oportunidad/listar-oportunidades-by-ruc-est');
    final List<Opportunity> opportunities = [];
    for (final opportunity in response.data['data'] ?? []) {
      opportunities.add(OpportunityMapper.jsonToEntity(opportunity));
    }

    return opportunities;
  }
}

import 'package:crm_app/features/kpis/infrastructure/mappers/kpi_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';

import '../errors/kpi_errors.dart';
import '../mappers/kpi_mapper.dart';

class KpisDatasourceImpl extends KpisDatasource {
  late final Dio dio;
  final String accessToken;

  KpisDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<KpiResponse> createUpdateKpi(Map<dynamic, dynamic> kpiLike) async {
    try {
      final String? id = kpiLike['OBJR_ID_OBJETIVO'];
      print('ID CREATE: ${id}');
      final String method = 'POST';
      final String url = (id == null)
          ? '/objetivo/create-objetivo'
          : '/objetivo/edit-objetivo';

      print('KPILIKE: ${kpiLike}');

      print('URL: ${url}');

      if (id == null) {
        kpiLike.remove('OBJR_ID_OBJETIVO');
      }

      final response = await dio.request(url,
          data: kpiLike, options: Options(method: method));

      print('RESP:${response}');

      final KpiResponse kpiResponse =
          KpiResponseMapper.jsonToEntity(response.data);

      if (kpiResponse.status == true) {
        kpiResponse.kpi = KpiMapper.jsonToEntity(response.data['data']);
      }

      return kpiResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw KpiNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Kpi> getKpiById(String id) async {
    try {
      final response = await dio.get('/objetivo/listar-objetivo-by-id/$id');
      final Kpi kpi = KpiMapper.jsonToEntity(response.data['data']);

      return kpi;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw KpiNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Kpi>> getKpis() async {
    final response = await dio.post('/objetivo/listar-objetivo-by-asignacion');
    final List<Kpi> kpis = [];
    for (final kpi in response.data['data'] ?? []) {
      kpis.add(KpiMapper.jsonToEntity(kpi));
    }

    return kpis;
  }
}

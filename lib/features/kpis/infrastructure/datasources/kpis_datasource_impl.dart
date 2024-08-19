import 'dart:developer';

import 'package:crm_app/features/kpis/domain/entities/objetive_by_category.dart';
import 'package:crm_app/features/kpis/infrastructure/mappers/objetive_by_category_mapper.dart';

import '../../domain/entities/periodicidad.dart';
import '../mappers/kpi_response_mapper.dart';
import '../mappers/periodicidad_mapper.dart';
import 'package:dio/dio.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

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
      const String method = 'POST';
      final String url = (id == null)
          ? '/objetivo/create-objetivo'
          : '/objetivo/edit-objetivo';

      if (id == null) {
        kpiLike.remove('OBJR_ID_OBJETIVO');
      }

      final response = await dio.request(url,
          data: kpiLike, options: Options(method: method));

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
    final response = await dio.get('/objetivo/listar-objetivo-dashboard');

    final List<Kpi> kpis = [];
    for (final kpi in response.data['data'] ?? []) {
      kpis.add(KpiMapper.jsonToEntity(kpi));
    }

    return kpis;
  }

  @override
  Future<List<Periodicidad>> getPeriodicidades() async {
    final response = await dio.get('/objetivo/listar-periodicidad');
    final List<Periodicidad> periodicidades = [];
    for (final periodicidad in response.data['data'] ?? []) {
      periodicidad['PEOB_ID_PERIODICIDAD_CALENDARIO'] =
          periodicidad['PERI_ID_PERIODICIDAD_CALENDARIO'];
      periodicidades.add(PeriodicidadMapper.jsonToEntity(periodicidad));
    }

    return periodicidades;
  }

  @override
  Future<List<ObjetiveByCategory>> listObjetiveByCategory(
    Map<dynamic, dynamic> kpiForm,
  ) async {
    final kpiFormData = kpiForm;
    try {
      log(Environment.apiUrl.toString());
      log(kpiFormData.toString());
      final response = await dio.post(
        '/objetivo/listar-objetivo-by-categoria',
        data: kpiFormData,
      );
      log(response.statusCode.toString());
      log(response.realUri.path.toString());
      log(response.data.toString());

      final List<ObjetiveByCategory> listObjetiveCategory = [];
      final listData = response.data['data'] as List;
      log(response.data.toString());
      for (final item in listData) {
        final tempItem = ObjetiveByCategoryMapper.jsonToEntity(item);
        listObjetiveCategory.add(tempItem);
      }
      return listObjetiveCategory;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}

import 'package:crm_app/features/kpis/domain/entities/objetive_by_category_response.dart';

import '../domain.dart';
import '../entities/periodicidad.dart';

abstract class KpisDatasource {
  Future<List<Kpi>> getKpis(String idUsuario);
  Future<Kpi> getKpiById(String id);

  Future<KpiResponse> createUpdateKpi(Map<dynamic, dynamic> kpiLike);

  Future<List<Periodicidad>> getPeriodicidades();

  Future<ObjetiveByCategoryResponse> listObjetiveByCategory(
    Map<dynamic, dynamic> kpiForm,
  );

}

import 'package:crm_app/features/kpis/domain/entities/objetive_by_category.dart';

import '../domain.dart';
import '../entities/periodicidad.dart';

abstract class KpisDatasource {
  Future<List<Kpi>> getKpis();
  Future<Kpi> getKpiById(String id);

  Future<KpiResponse> createUpdateKpi(Map<dynamic, dynamic> kpiLike);

  Future<List<Periodicidad>> getPeriodicidades();

  Future<List<ObjetiveByCategory>> listObjetiveByCategory(
    Map<dynamic, dynamic> kpiForm,
  );

}

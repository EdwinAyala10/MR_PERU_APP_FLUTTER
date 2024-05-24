import '../domain.dart';
import '../entities/periodicidad.dart';

abstract class KpisDatasource {

  Future<List<Kpi>> getKpis();
  Future<Kpi> getKpiById(String id);

  Future<KpiResponse> createUpdateKpi( Map<dynamic,dynamic> kpiLike );

  Future<List<Periodicidad>> getPeriodicidades();

}


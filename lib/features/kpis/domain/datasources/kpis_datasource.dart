import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/entities/periodicidad.dart';

abstract class KpisDatasource {

  Future<List<Kpi>> getKpis();
  Future<Kpi> getKpiById(String id);

  Future<KpiResponse> createUpdateKpi( Map<dynamic,dynamic> kpiLike );

  Future<List<Periodicidad>> getPeriodicidades();

}


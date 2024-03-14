import 'package:crm_app/features/kpis/domain/domain.dart';

abstract class KpisDatasource {

  Future<List<Kpi>> getKpis();
  Future<Kpi> getKpiById(String id);

  Future<KpiResponse> createUpdateKpi( Map<dynamic,dynamic> kpiLike );

}


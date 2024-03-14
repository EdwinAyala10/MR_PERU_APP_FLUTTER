import 'package:crm_app/features/kpis/domain/domain.dart';

class KpisRepositoryImpl extends KpisRepository {

  final KpisDatasource datasource;

  KpisRepositoryImpl(this.datasource);

  @override
  Future<KpiResponse> createUpdateKpi(Map<dynamic, dynamic> kpiLike) {
    return datasource.createUpdateKpi(kpiLike);
  }

  @override
  Future<Kpi> getKpiById(String id) {
    return datasource.getKpiById(id);
  }

  @override
  Future<List<Kpi>> getKpis() {
    return datasource.getKpis();
  }

}
import 'package:crm_app/features/kpis/domain/entities/objetive_by_category.dart';
import 'package:crm_app/features/kpis/domain/entities/objetive_by_category_response.dart';

import '../../domain/domain.dart';
import '../../domain/entities/periodicidad.dart';

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
  Future<List<Kpi>> getKpis(String idUsuario) {
    return datasource.getKpis(idUsuario);
  }

  @override
  Future<List<Periodicidad>> getPeriodicidades() {
    return datasource.getPeriodicidades();
  }

  @override
  Future< 
   ObjetiveByCategoryResponse> listObjetiveByCategory(
    Map<dynamic, dynamic> kpiForm,
  ) {
    return datasource.listObjetiveByCategory(kpiForm);
  }

  @override
  Future<KpiResponse> updateOrderKpis({ String idKpiOld = '', String orderKpiOld = '', String idKpiNew = '', String orderKpiNew = '' }) {
    return datasource.updateOrderKpis(idKpiOld : idKpiOld, orderKpiOld: orderKpiOld, idKpiNew: idKpiNew, orderKpiNew: orderKpiNew);
  }

}

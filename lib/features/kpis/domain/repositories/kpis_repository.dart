import 'package:crm_app/features/kpis/domain/entities/objetive_by_category_response.dart';
import 'package:crm_app/features/users/domain/domain.dart';

import '../domain.dart';
import '../entities/periodicidad.dart';

abstract class KpisRepository {
  Future<List<Kpi>> getKpis(String idUsuario);
  Future<Kpi> getKpiById(String id);

  Future<KpiResponse> createUpdateKpi(Map<dynamic, dynamic> kpiLike);

  Future<List<Periodicidad>> getPeriodicidades();

  Future<ObjetiveByCategoryResponse> listObjetiveByCategory(
    Map<dynamic, dynamic> kpiForm,
  );

  Future<KpiResponse> updateOrderKpis(
      {String idKpiOld = '',
      String orderKpiOld = '',
      String idKpiNew = '',
      String orderKpiNew = ''});

  Future<List<KpisByAsesor>> getKpisByAsesor(String idUsuarioAsignacion);

  // User reorder methods
  Future<List<UserMaster>> getUsersByType(String search);
  Future<bool> updateUsersOrder(List<Map<String, String>> usuarios);
  Future<List<KpiStats>> getKpiStats(String userId, int year);
}

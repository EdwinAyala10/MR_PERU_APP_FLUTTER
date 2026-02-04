import 'package:crm_app/features/route-planner/domain/entities/distance_filter.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_activity.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_distrito.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_option.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_responsable.dart';
import '../domain.dart';
import '../entities/check_in_by_ruc_local_response.dart';

abstract class CompaniesRepository {
  Future<List<Company>> getCompanies({
    int limit = 10,
    int offset = 0,
    String search = '',
    List<FilterOption> filters = const [],
    double? latMin,
    double? latMax,
    double? lngMin,
    double? lngMax,
  });
  Future<Company> getCompanyById(String rucId, String userId);

  Future<CompanyResponse> createUpdateCompany(
      Map<dynamic, dynamic> companyLike);

  Future<List<Company>> searchCompaniesActive(String dni, String query);

  Future<CompanyCheckInResponse> createCompanyCheckIn(
      Map<dynamic, dynamic> companyCheckInLike);

  Future<List<CompanyLocal>> getCompanyLocales(String ruc);

  Future<CompanyLocal> getLocalById(String rucId, String localId);

  Future<CompanyLocalResponse> createUpdateCompanyLocal(
      Map<dynamic, dynamic> companyLocalLike);

  Future<List<CompanyLocal>> searchCompanyLocalesActive(
      String ruc, String query);

  Future<CheckInByRucLocalResponse> getCheckInByRucLocal(
      String ruc, String user);

  // Filters
  Future<List<FilterResponsable>> getFilterResponsable({String search});
  Future<List<FilterActivity>> getFilterActividad();
  Future<List<FilterDepartamento>> getFilterDepartamento({String search});
  Future<List<FilterProvincia>> getFilterProvincia(
      {String search, String departamento});
  Future<List<FilterDistrito>> getFilterDistrito(
      {String search, String provincia});
  Future<List<FilterEstado>> getFilterEstado();
  Future<List<DistanceFilter>> getDistanceFilters();

  // Obtener coordenadas de empresas desde listar-clientes-local
  Future<Map<String, Map<String, String?>>> getCompanyCoordinates({
    int limit = 10,
    int offset = 0,
    String search = '',
    List<FilterOption> filters = const [],
  });
}

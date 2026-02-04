import 'package:crm_app/features/route-planner/domain/entities/distance_filter.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_activity.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_distrito.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_option.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_responsable.dart';
import '../../domain/domain.dart';
import '../../domain/entities/check_in_by_ruc_local_response.dart';

class CompaniesRepositoryImpl extends CompaniesRepository {
  final CompaniesDatasource datasource;

  CompaniesRepositoryImpl(this.datasource);

  @override
  Future<CompanyResponse> createUpdateCompany(
      Map<dynamic, dynamic> companyLike) {
    return datasource.createUpdateCompany(companyLike);
  }

  @override
  Future<Company> getCompanyById(String rucId, String userId) {
    return datasource.getCompanyById(rucId, userId);
  }

  @override
  Future<List<Company>> getCompanies({
    int limit = 10,
    int offset = 0,
    String search = '',
    List<FilterOption> filters = const [],
    double? latMin,
    double? latMax,
    double? lngMin,
    double? lngMax,
  }) {
    return datasource.getCompanies(
      limit: limit,
      offset: offset,
      search: search,
      filters: filters,
      latMin: latMin,
      latMax: latMax,
      lngMin: lngMin,
      lngMax: lngMax,
    );
  }

  @override
  Future<List<Company>> searchCompaniesActive(String dni, String query) {
    return datasource.searchCompaniesActive(dni, query);
  }

  @override
  Future<CompanyCheckInResponse> createCompanyCheckIn(
      Map<dynamic, dynamic> companyCheckInLike) {
    return datasource.createCompanyCheckIn(companyCheckInLike);
  }

  @override
  Future<CompanyLocalResponse> createUpdateCompanyLocal(Map companyLocalLike) {
    return datasource.createUpdateCompanyLocal(companyLocalLike);
  }

  @override
  Future<List<CompanyLocal>> getCompanyLocales(String ruc) {
    return datasource.getCompanyLocales(ruc);
  }

  @override
  Future<CompanyLocal> getLocalById(String rucId, String localId) {
    return datasource.getLocalById(rucId, localId);
  }

  @override
  Future<List<CompanyLocal>> searchCompanyLocalesActive(
      String ruc, String query) {
    return datasource.searchCompanyLocalesActive(ruc, query);
  }

  @override
  Future<CheckInByRucLocalResponse> getCheckInByRucLocal(
      String ruc, String user) {
    return datasource.getCheckInByRucLocal(ruc, user);
  }

  @override
  Future<List<FilterActivity>> getFilterActividad() {
    return datasource.getFilterActividad();
  }

  @override
  Future<List<FilterDepartamento>> getFilterDepartamento({String search = ''}) {
    return datasource.getFilterDepartamento(search: search);
  }

  @override
  Future<List<FilterDistrito>> getFilterDistrito(
      {String search = '', String provincia = ''}) {
    return datasource.getFilterDistrito(search: search, provincia: provincia);
  }

  @override
  Future<List<FilterEstado>> getFilterEstado() {
    return datasource.getFilterEstado();
  }

  @override
  Future<List<FilterProvincia>> getFilterProvincia(
      {String search = '', String departamento = ''}) {
    return datasource.getFilterProvincia(
        search: search, departamento: departamento);
  }

  @override
  Future<List<FilterResponsable>> getFilterResponsable({String search = ''}) {
    return datasource.getFilterResponsable(search: search);
  }

  @override
  Future<List<DistanceFilter>> getDistanceFilters() {
    return datasource.getDistanceFilters();
  }

  @override
  Future<Map<String, Map<String, String?>>> getCompanyCoordinates({
    int limit = 10,
    int offset = 0,
    String search = '',
    List<FilterOption> filters = const [],
  }) {
    return datasource.getCompanyCoordinates(
      limit: limit,
      offset: offset,
      search: search,
      filters: filters,
    );
  }
}

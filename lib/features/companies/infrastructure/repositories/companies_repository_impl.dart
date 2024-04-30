import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/domain/entities/check_in_by_ruc_local_response.dart';

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
  Future<List<Company>> getCompanies({ int limit = 10, int offset = 0, String search = '' }) {
    return datasource.getCompanies(limit: limit, offset: offset, search: search);
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
  Future<List<CompanyLocal>> searchCompanyLocalesActive(
      String ruc, String query) {
    return datasource.searchCompanyLocalesActive(ruc, query);
  }

  @override
  Future<CheckInByRucLocalResponse> getCheckInByRucLocal(
      String ruc, String user) {
    return datasource.getCheckInByRucLocal(ruc, user);
  }
}

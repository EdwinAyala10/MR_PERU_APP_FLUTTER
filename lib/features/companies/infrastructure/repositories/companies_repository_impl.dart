import 'package:crm_app/features/companies/domain/domain.dart';

class CompaniesRepositoryImpl extends CompaniesRepository {

  final CompaniesDatasource datasource;

  CompaniesRepositoryImpl(this.datasource);

  @override
  Future<CompanyResponse> createUpdateCompany(Map<dynamic, dynamic> companyLike) {
    return datasource.createUpdateCompany(companyLike);
  }

  @override
  Future<Company> getCompanyById(String rucId) {
    return datasource.getCompanyById(rucId);
  }

  @override
  Future<List<Company>> getCompanies() {
    return datasource.getCompanies();
  }
  
  @override
  Future<List<Company>> searchCompaniesActive(String dni, String query) {
    return datasource.searchCompaniesActive(dni, query);
  }

  @override
  Future<CompanyCheckInResponse> createCompanyCheckIn(Map<dynamic,dynamic> companyCheckInLike) {
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
}
import 'package:crm_app/features/companies/domain/domain.dart';

abstract class CompaniesDatasource {

  Future<List<Company>> getCompanies();
  Future<Company> getCompanyById(String rucId);

  Future<CompanyResponse> createUpdateCompany( Map<dynamic,dynamic> companyLike );
  
  Future<List<Company>> searchCompaniesActive(String dni, String query);

  Future<CompanyCheckInResponse> createCompanyCheckIn( Map<dynamic,dynamic> companyCheckInLike );

  Future<List<CompanyLocal>> getCompanyLocales(String ruc);

  Future<CompanyLocalResponse> createUpdateCompanyLocal( Map<dynamic,dynamic> companyLocalLike );
}


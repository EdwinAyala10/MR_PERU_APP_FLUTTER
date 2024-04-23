import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/domain/entities/check_in_by_ruc_local_response.dart';

abstract class CompaniesDatasource {

  Future<List<Company>> getCompanies();
  Future<Company> getCompanyById(String rucId, String userId);

  Future<CompanyResponse> createUpdateCompany( Map<dynamic,dynamic> companyLike );
  
  Future<List<Company>> searchCompaniesActive(String dni, String query);

  Future<CompanyCheckInResponse> createCompanyCheckIn( Map<dynamic,dynamic> companyCheckInLike );

  Future<List<CompanyLocal>> getCompanyLocales(String ruc);

  Future<CompanyLocalResponse> createUpdateCompanyLocal( Map<dynamic,dynamic> companyLocalLike );

  Future<List<CompanyLocal>> searchCompanyLocalesActive(String ruc, String query);

  Future<CheckInByRucLocalResponse> getCheckInByRucLocal( String ruc, String user );

}


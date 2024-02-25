import 'package:crm_app/features/companies/domain/domain.dart';

abstract class CompaniesDatasource {

  Future<List<Company>> getCompanies();
  Future<Company> getCompanyById(String rucId);

  Future<CompanyResponse> createUpdateCompany( Map<dynamic,dynamic> companyLike );

}


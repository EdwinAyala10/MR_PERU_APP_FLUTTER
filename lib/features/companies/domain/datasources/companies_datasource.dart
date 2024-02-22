import '../entities/company.dart';

abstract class CompaniesDatasource {

  Future<List<Company>> getCompanies();
  Future<Company> getCompanyById(String ruc);

  Future<Company> createUpdateCompany( Map<String,dynamic> companytLike );

}


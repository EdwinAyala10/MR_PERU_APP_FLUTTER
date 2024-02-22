import 'dart:ffi';

import 'package:crm_app/features/companies/domain/domain.dart';


class CompaniesRepositoryImpl extends CompaniesRepository {

  final CompaniesDatasource datasource;

  CompaniesRepositoryImpl(this.datasource);


  @override
  Future<Bool> createUpdateCompany(Map<String, dynamic> companyLike) {
    return datasource.createUpdateCompany(companyLike);
  }

  @override
  Future<Company> getCompanyById(String ruc) {
    return datasource.getCompanyById(ruc);
  }

  @override
  Future<List<Company>> getCompanies() {
    return datasource.getCompanies();
  }

}
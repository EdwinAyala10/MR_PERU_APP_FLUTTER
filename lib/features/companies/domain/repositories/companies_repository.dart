

import 'dart:ffi';

import '../entities/company.dart';

abstract class CompaniesRepository {

  Future<List<Company>> getCompanies();
  Future<Company> getCompanyById(String ruc);

  Future<Bool> createUpdateCompany( Map<String,dynamic> companyLike );

}


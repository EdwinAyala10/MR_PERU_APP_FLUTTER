import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/infrastructure/datasources/companies_datasource_impl.dart';
import 'package:crm_app/features/companies/infrastructure/repositories/companies_repository_impl.dart';


final companiesRepositoryProvider = Provider<CompaniesRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final companiesRepository = CompaniesRepositoryImpl(
    CompaniesDatasourceImpl(accessToken: accessToken )
  );

  return companiesRepository;
});


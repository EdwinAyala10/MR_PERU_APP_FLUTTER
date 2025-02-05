import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import '../../infrastructure/datasources/companies_datasource_impl.dart';
import '../../infrastructure/repositories/companies_repository_impl.dart';


final companiesRepositoryProvider = Provider<CompaniesRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final companiesRepository = CompaniesRepositoryImpl(
    CompaniesDatasourceImpl(accessToken: accessToken )
  );

  return companiesRepository;
});


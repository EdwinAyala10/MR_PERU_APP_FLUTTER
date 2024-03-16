import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/infrastructure/datasources/opportunities_datasource_impl.dart';
import 'package:crm_app/features/opportunities/infrastructure/repositories/opportunities_repository_impl.dart';


final opportunitiesRepositoryProvider = Provider<OpportunitiesRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final opportunitiesRepository = OpportunitiesRepositoryImpl(
    OpportunitiesDatasourceImpl(accessToken: accessToken )
  );

  return opportunitiesRepository;
});


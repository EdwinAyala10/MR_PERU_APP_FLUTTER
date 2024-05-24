import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import '../../infrastructure/datasources/opportunities_datasource_impl.dart';
import '../../infrastructure/repositories/opportunities_repository_impl.dart';


final opportunitiesRepositoryProvider = Provider<OpportunitiesRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final opportunitiesRepository = OpportunitiesRepositoryImpl(
    OpportunitiesDatasourceImpl(accessToken: accessToken )
  );

  return opportunitiesRepository;
});


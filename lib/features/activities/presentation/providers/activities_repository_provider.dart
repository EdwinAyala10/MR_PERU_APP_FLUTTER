import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import '../../infrastructure/datasources/activities_datasource_impl.dart';
import '../../infrastructure/repositories/activities_repository_impl.dart';


final activitiesRepositoryProvider = Provider<ActivitiesRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final activitiesRepository = ActivitiesRepositoryImpl(
    ActivitiesDatasourceImpl(accessToken: accessToken )
  );

  return activitiesRepository;
});


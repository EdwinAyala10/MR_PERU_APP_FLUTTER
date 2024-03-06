import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/infrastructure/datasources/activities_datasource_impl.dart';
import 'package:crm_app/features/activities/infrastructure/repositories/activities_repository_impl.dart';


final activitiesRepositoryProvider = Provider<ActivitiesRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final activitiesRepository = ActivitiesRepositoryImpl(
    ActivitiesDatasourceImpl(accessToken: accessToken )
  );

  return activitiesRepository;
});


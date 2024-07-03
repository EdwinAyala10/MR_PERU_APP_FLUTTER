import 'package:crm_app/features/route-planner/infrastructure/infrastructure.dart';
import 'package:crm_app/features/route-planner/infrastructure/repositories/route_planner_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';


final routePlannerRepositoryProvider = Provider<RoutePlannerRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final routePlannerRepository = RoutePlannerRepositoryImpl(
    RoutePlannerDatasourceImpl(accessToken: accessToken )
  );

  return routePlannerRepository;
});


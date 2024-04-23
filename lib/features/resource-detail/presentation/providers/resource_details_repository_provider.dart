import 'package:crm_app/features/resource-detail/domain/domain.dart';
import 'package:crm_app/features/resource-detail/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';


final resourceDetailsRepositoryProvider = Provider<ResourceDetailsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final resourceDetailsRepository = ResourceDetailsRepositoryImpl(
    ResourceDetailsDatasourceImpl(accessToken: accessToken )
  );

  return resourceDetailsRepository;
});


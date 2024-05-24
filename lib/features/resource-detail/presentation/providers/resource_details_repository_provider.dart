import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';


final resourceDetailsRepositoryProvider = Provider<ResourceDetailsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final resourceDetailsRepository = ResourceDetailsRepositoryImpl(
    ResourceDetailsDatasourceImpl(accessToken: accessToken )
  );

  return resourceDetailsRepository;
});


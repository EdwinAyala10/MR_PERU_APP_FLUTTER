import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import '../../infrastructure/datasources/kpis_datasource_impl.dart';
import '../../infrastructure/repositories/kpis_repository_impl.dart';


final kpisRepositoryProvider = Provider<KpisRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final kpisRepository = KpisRepositoryImpl(
    KpisDatasourceImpl(accessToken: accessToken )
  );

  return kpisRepository;
});


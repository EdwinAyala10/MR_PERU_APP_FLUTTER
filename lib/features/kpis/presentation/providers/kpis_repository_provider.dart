import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/infrastructure/datasources/kpis_datasource_impl.dart';
import 'package:crm_app/features/kpis/infrastructure/repositories/kpis_repository_impl.dart';


final kpisRepositoryProvider = Provider<KpisRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final kpisRepository = KpisRepositoryImpl(
    KpisDatasourceImpl(accessToken: accessToken )
  );

  return kpisRepository;
});


import 'package:crm_app/features/indicators/domain/repositories/indicators_repository.dart';
import 'package:crm_app/features/indicators/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';

final indicatorsRepositoryProvider = Provider<IndicatorsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final indicatorsRepository = IndicatorsRepositoryImpl(
    IndicatorsDatasourceImpl(accessToken: accessToken )
  );

  return indicatorsRepository;
});


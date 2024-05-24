import '../../domain/repositories/indicators_repository.dart';
import '../../infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final indicatorsRepositoryProvider = Provider<IndicatorsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final indicatorsRepository = IndicatorsRepositoryImpl(
    IndicatorsDatasourceImpl(accessToken: accessToken )
  );

  return indicatorsRepository;
});


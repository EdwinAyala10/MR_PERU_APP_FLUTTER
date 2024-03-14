import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';

import 'kpis_repository_provider.dart';

final kpiProvider = StateNotifierProvider.autoDispose
    .family<KpiNotifier, KpiState, String>((ref, id) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return KpiNotifier(kpisRepository: kpisRepository, user: user!, id: id);
});

class KpiNotifier extends StateNotifier<KpiState> {
  final KpisRepository kpisRepository;
  final User user;

  KpiNotifier({
    required this.kpisRepository,
    required this.user,
    required String id,
  }) : super(KpiState(id: id)) {
    loadKpi();
  }

  Kpi newEmptyKpi() {
    return Kpi(
      id: 'new',
      objrIdAsignacion: '',
      objrIdCategoria: '',
      objrIdPeriodicidad: '',
      objrIdTipo: '',
      objrIdUsuarioRegistro: user.code,
      objrNombreUsuarioRegistro: user.name,
      objrIdUsuarioResponsable: user.code,
      objrNombreUsuarioResponsable: user.name,
      objrNombre: '',
      objrObservaciones: '',
    );
  }

  Future<void> loadKpi() async {
    print('ANTES TRY');
    try {
      print('STATE ID LOAD KPI: ${state.id}');

      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          kpi: newEmptyKpi(),
        );

        return;
      }

      final kpi = await kpisRepository.getKpiById(state.id);

      state = state.copyWith(isLoading: false, kpi: kpi);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class KpiState {
  final String id;
  final Kpi? kpi;
  final bool isLoading;
  final bool isSaving;

  KpiState({
    required this.id,
    this.kpi,
    this.isLoading = true,
    this.isSaving = false,
  });

  KpiState copyWith({
    String? id,
    Kpi? kpi,
    bool? isLoading,
    bool? isSaving,
  }) =>
      KpiState(
        id: id ?? this.id,
        kpi: kpi ?? this.kpi,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/periodicidad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

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

  Kpi newEmptyKpi(List<Periodicidad> periodicidades) {
    return Kpi(
      id: 'new',
      objrIdAsignacion: '01',
      objrIdCategoria: '01',
      objrIdPeriodicidad: '01',
      objrIdTipo: '01',
      objrIdUsuarioRegistro: user.code,
      objrNombreUsuarioRegistro: user.name,
      objrIdUsuarioResponsable: user.code,
      objrNombreUsuarioResponsable: user.name,
      objrNombre: '',
      objrCantidad: '0',
      objrObservaciones: '',
      objrValorDifMes: false,
      arrayuserasignacion: [],
      peobIdPeriodicidad: periodicidades,
    );
  }

  Future<void> loadKpi() async {
    try {
      if (state.id == 'new') {
        final periodicidades = await kpisRepository.getPeriodicidades();

        state = state.copyWith(
          isLoading: false,
          kpi: newEmptyKpi(periodicidades),
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
  final List<Periodicidad>? periodicidades;
  final bool isLoading;
  final bool isSaving;

  KpiState({
    required this.id,
    this.kpi,
    this.periodicidades,
    this.isLoading = true,
    this.isSaving = false,
  });

  KpiState copyWith({
    String? id,
    Kpi? kpi,
    List<Periodicidad>? periodicidades,
    bool? isLoading,
    bool? isSaving,
  }) =>
      KpiState(
        id: id ?? this.id,
        kpi: kpi ?? this.kpi,
        periodicidades: periodicidades ?? this.periodicidades,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

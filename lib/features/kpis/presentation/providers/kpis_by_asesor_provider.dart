import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kpis_repository_provider.dart';

final kpisByAsesorProvider =
    StateNotifierProvider<KpisByAsesorNotifier, KpisByAsesorState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return KpisByAsesorNotifier(
    kpisRepository: kpisRepository,
    user: user!,
  );
});

class KpisByAsesorNotifier extends StateNotifier<KpisByAsesorState> {
  final KpisRepository kpisRepository;
  final User user;

  KpisByAsesorNotifier({
    required this.kpisRepository,
    required this.user,
  }) : super(KpisByAsesorState()) {
    loadKpis();
  }

  Future loadKpis() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final kpis = await kpisRepository.getKpisByAsesor(user.code.trim());
      state = state.copyWith(
        isLoading: false,
        kpis: kpis,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

class KpisByAsesorState {
  final bool isLoading;
  final List<KpisByAsesor> kpis;

  KpisByAsesorState({
    this.isLoading = false,
    this.kpis = const [],
  });

  KpisByAsesorState copyWith({
    bool? isLoading,
    List<KpisByAsesor>? kpis,
  }) {
    return KpisByAsesorState(
      isLoading: isLoading ?? this.isLoading,
      kpis: kpis ?? this.kpis,
    );
  }
}

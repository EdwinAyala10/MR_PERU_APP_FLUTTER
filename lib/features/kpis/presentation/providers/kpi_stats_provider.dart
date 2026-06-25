import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import 'kpis_repository_provider.dart';

final kpiStatsProvider =
    StateNotifierProvider<KpiStatsNotifier, KpiStatsState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return KpiStatsNotifier(
    kpisRepository: kpisRepository,
    userCode: user!.code,
  );
});

class KpiStatsNotifier extends StateNotifier<KpiStatsState> {
  final KpisRepository kpisRepository;
  final String userCode;
  String? selectedUserId;

  KpiStatsNotifier({
    required this.kpisRepository,
    required this.userCode,
  }) : super(KpiStatsState(year: DateTime.now().year)) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);

    try {
      // Si hay un userId seleccionado (admin), usar ese, sino usar el código del usuario actual
      final userIdToUse = selectedUserId ?? userCode;
      final stats = await kpisRepository.getKpiStats(userIdToUse, state.year);
      state = state.copyWith(
        isLoading: false,
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setYear(int year) {
    if (state.year == year) return;
    state = state.copyWith(year: year);
    loadStats();
  }

  void setSelectedUserId(String? userId) {
    if (selectedUserId == userId) return;
    selectedUserId = userId;
    state = state.copyWith(selectedUserId: userId);
    loadStats();
  }
}

class KpiStatsState {
  final bool isLoading;
  final List<KpiStats> stats;
  final int year;
  final String? selectedUserId;

  KpiStatsState({
    this.isLoading = false,
    this.stats = const [],
    required this.year,
    this.selectedUserId,
  });

  KpiStatsState copyWith({
    bool? isLoading,
    List<KpiStats>? stats,
    int? year,
    String? selectedUserId,
  }) {
    return KpiStatsState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      year: year ?? this.year,
      selectedUserId: selectedUserId ?? this.selectedUserId,
    );
  }
}

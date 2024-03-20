import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';

import 'kpis_repository_provider.dart';

final kpisProvider =
    StateNotifierProvider<KpisNotifier, KpisState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);
  return KpisNotifier(kpisRepository: kpisRepository);
});

class KpisNotifier extends StateNotifier<KpisState> {
  final KpisRepository kpisRepository;

  KpisNotifier({required this.kpisRepository})
      : super(KpisState()) {
    loadNextPage();
  }

  Future<CreateUpdateKpiResponse> createOrUpdateKpi(
      Map<dynamic, dynamic> kpiLike) async {
    try {
      final kpiResponse =
          await kpisRepository.createUpdateKpi(kpiLike);

      final message = kpiResponse.message;

      if (kpiResponse.status) {

        final kpi = kpiResponse.kpi as Kpi;
        final isKpiInList =
            state.kpis.any((element) => element.id == kpi.id);

        if (!isKpiInList) {
          state = state.copyWith(kpis: [...state.kpis, kpi]);
          return CreateUpdateKpiResponse(response: true, message: message);
        }

        state = state.copyWith(
            kpis: state.kpis
                .map(
                  (element) => (element.id == kpi.id) ? kpi : element,
                )
                .toList());

        return CreateUpdateKpiResponse(response: true, message: message);
      }

      return CreateUpdateKpiResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateKpiResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final kpis = await kpisRepository.getKpis();

    if (kpis.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        kpis: kpis
    );

    /*state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        kpis: [...state.kpis, ...kpis]);*/
  }

  /*Future loadKpisDashboard() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final kpis = await kpisRepository.getKpisForDashboard();

    if (kpis.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        kpis: [...state.kpis, ...kpis]);
  }*/
}



class KpisState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Kpi> kpis;

  KpisState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.kpis = const []});

  KpisState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Kpi>? kpis,
  }) =>
      KpisState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        kpis: kpis ?? this.kpis,
      );
}

import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/entities/objetive_by_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kpis_repository_provider.dart';

final selecIndexViewProvider = StateProvider<int>((ref) => 1);

final goalsModelProvider = StateProvider<Kpi?>((ref) => null);

final kpisProvider = StateNotifierProvider<KpisNotifier, KpisState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);
  return KpisNotifier(kpisRepository: kpisRepository);
});

class KpisNotifier extends StateNotifier<KpisState> {
  final KpisRepository kpisRepository;

  KpisNotifier({required this.kpisRepository}) : super(KpisState()) {
    loadNextPage();
  }

  Future<CreateUpdateKpiResponse> createOrUpdateKpi(
      Map<dynamic, dynamic> kpiLike) async {
    try {
      final kpiResponse = await kpisRepository.createUpdateKpi(kpiLike);

      final message = kpiResponse.message;

      if (kpiResponse.status) {
        //final kpi = kpiResponse.kpi as Kpi;
        //final isKpiInList = state.kpis.any((element) => element.id == kpi.id);

        /*if (!isKpiInList) {
          state = state.copyWith(kpis: [...state.kpis, kpi]);
          return CreateUpdateKpiResponse(response: true, message: message);
        }

        state = state.copyWith(
            kpis: state.kpis
                .map(
                  (element) => (element.id == kpi.id) ? kpi : element,
                )
                .toList());*/

        return CreateUpdateKpiResponse(response: true, message: message);
      }

      return CreateUpdateKpiResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateKpiResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future loadNextPage() async {
    print('cargar KPIS');
    //if (state.isLoading || state.isLastPage) return;
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final kpis = await kpisRepository.getKpis();

    if (kpis.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true);
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(
        //isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        kpis: kpis);

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

final goalsByCatProvider =
    StateNotifierProvider<GoalsByCatNotifier, GoalsByCatState>(
  (ref) {
    final kpiRepository = ref.watch(kpisRepositoryProvider);
    final lastKpi = ref.watch(goalsModelProvider);
    return GoalsByCatNotifier(kpiRepository: kpiRepository, lastKpi: lastKpi);
  },
);

class GoalsByCatNotifier extends StateNotifier<GoalsByCatState> {
  final KpisRepository kpiRepository;
  final Kpi? lastKpi;
  GoalsByCatNotifier({
    this.lastKpi,
    required this.kpiRepository,
  }) : super(GoalsByCatState()) {
    listgoalsByCategories();
  }

  Future<void> listgoalsByCategories() async {
    final form = <String, dynamic>{
      'OBJR_ID_CATEGORIA': lastKpi?.objrIdCategoria,
      'OBJR_ID_OBJETIVO': lastKpi?.id,
      'SEARCH': '',
    };
    final response = await kpiRepository.listObjetiveByCategory(form);
    if (response.isEmpty) {
      state = state.copyWith(
        type: "full",
        icon: "",
        status: false,
        message: "Empty objetive category",
        goalsbycat: [],
      );
      return;
    }
    state = state.copyWith(
      goalsbycat: response,
    );
  }
}

class GoalsByCatState {
  final bool? isLastPage;
  final int? limit;
  final int? offset;
  final bool? isLoading;
  final List<ObjetiveByCategory>? goalsbycat;

  GoalsByCatState({
    this.goalsbycat,
    this.isLastPage = false,
    this.limit = 10,
    this.offset = 0,
    this.isLoading = false,
  });
  GoalsByCatState copyWith({
    String? type,
    String? icon,
    bool? status,
    String? message,
    List<ObjetiveByCategory>? goalsbycat,
  }) {
    return GoalsByCatState(
      isLastPage: isLastPage,
      isLoading: isLoading,
      limit: limit,
      offset: offset,
      goalsbycat: goalsbycat,
    );
  }
}

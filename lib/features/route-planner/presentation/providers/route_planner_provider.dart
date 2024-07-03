import 'package:crm_app/features/route-planner/presentation/providers/route_planner_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';


final routePlannerProvider =
    StateNotifierProvider<RoutePlannerNotifier, RoutePlannerState>((ref) {
  final routePlannerRepository = ref.watch(routePlannerRepositoryProvider);
  return RoutePlannerNotifier(routePlannerRepository: routePlannerRepository);
});


class RoutePlannerNotifier extends StateNotifier<RoutePlannerState> {
  final RoutePlannerRepository routePlannerRepository;

  RoutePlannerNotifier({required this.routePlannerRepository})
      : super(RoutePlannerState()) {
    loadNextPage(isRefresh: true);
  }

  void onChangeIsActiveSearch() {
    state = state.copyWith(
      isActiveSearch: true,
    );
  }

  void onChangeTextSearch(String text) {
    state = state.copyWith(textSearch: text);
    loadNextPage(isRefresh: true);
  }

  void onChangeNotIsActiveSearch() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
    loadNextPage(isRefresh: true);
    //}
  }

  Future loadNextPage({bool isRefresh = false}) async {
    final search = state.textSearch;

    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    }

    final locales = await routePlannerRepository.getCompanyLocals(
        search: search, limit: sLimit, offset: sOffset);

    if (locales.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    int newOffset;
    List<CompanyLocalRoutePlanner> newLocales;

    if (isRefresh) {
      newOffset = 0;
      newLocales = locales;
    } else {
      newOffset = state.offset + 10;
      newLocales = [...state.locales, ...locales];
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: newOffset,
        locales: newLocales);
  }

}

class RoutePlannerState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<CompanyLocalRoutePlanner> locales;
  final bool isActiveSearch;
  final String textSearch;

  RoutePlannerState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.locales = const []});

  RoutePlannerState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isActiveSearch,
    String? textSearch,
    List<CompanyLocalRoutePlanner>? locales,
  }) =>
      RoutePlannerState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        locales: locales ?? this.locales,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
        textSearch: textSearch ?? this.textSearch,
      );
}

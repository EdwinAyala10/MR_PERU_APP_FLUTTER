import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';

import 'opportunities_repository_provider.dart';

final opportunitiesProvider =
    StateNotifierProvider<OpportunitiesNotifier, OpportunitiesState>((ref) {
  final opportunitiesRepository = ref.watch(opportunitiesRepositoryProvider);
  return OpportunitiesNotifier(
      opportunitiesRepository: opportunitiesRepository);
});

class OpportunitiesNotifier extends StateNotifier<OpportunitiesState> {
  final OpportunitiesRepository opportunitiesRepository;

  OpportunitiesNotifier({required this.opportunitiesRepository})
      : super(OpportunitiesState()) {
    loadNextPage('');
  }

  Future<CreateUpdateOpportunityResponse> createOrUpdateOpportunity(
      Map<dynamic, dynamic> opportunityLike) async {
    try {
      final opportunityResponse = await opportunitiesRepository
          .createUpdateOpportunity(opportunityLike);

      final message = opportunityResponse.message;

      if (opportunityResponse.status) {
        final opportunity = opportunityResponse.opportunity as Opportunity;
        final isOpportunityInList =
            state.opportunities.any((element) => element.id == opportunity.id);

        if (!isOpportunityInList) {
          state = state
              .copyWith(opportunities: [opportunity, ...state.opportunities]);
          return CreateUpdateOpportunityResponse(
              response: true, message: message);
        }

        state = state.copyWith(
            opportunities: state.opportunities
                .map(
                  (element) =>
                      (element.id == opportunity.id) ? opportunity : element,
                )
                .toList());

        return CreateUpdateOpportunityResponse(
            response: true, message: message);
      }

      return CreateUpdateOpportunityResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateOpportunityResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

  void onChangeIsActiveSearch() {
    state = state.copyWith(
      isActiveSearch: true,
    );
  }

  void onChangeTextSearch(String text) {
    state = state.copyWith(textSearch: text);
    print('AAAAA');
    loadNextPage(text);
  }

  void onChangeNotIsActiveSearch() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
      loadNextPage('');
    //}
  }

  Future loadNextPage(String search) async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final opportunities =
        await opportunitiesRepository.getOpportunities('', search);

    if (opportunities.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        //opportunities: [...state.opportunities, ...opportunities]);
        opportunities: opportunities
    );
  }
}

class OpportunitiesState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Opportunity> opportunities;
  final bool isActiveSearch;
  final String textSearch;

  OpportunitiesState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.opportunities = const []});

  OpportunitiesState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Opportunity>? opportunities,
    bool? isActiveSearch,
    String? textSearch,
  }) =>
      OpportunitiesState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        opportunities: opportunities ?? this.opportunities,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
        textSearch: textSearch ?? this.textSearch,
      );
}

import '../../domain/entities/status_opportunity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

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
    loadNextPage(isRefresh: true);
  }

  Future<CreateUpdateOpportunityResponse> createOrUpdateOpportunity(
      Map<dynamic, dynamic> opportunityLike) async {
    try {
      final opportunityResponse = await opportunitiesRepository
          .createUpdateOpportunity(opportunityLike);

      final message = opportunityResponse.message;

      if (opportunityResponse.status) {
        /*final opportunity = opportunityResponse.opportunity as Opportunity;
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
                .toList());*/

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

    final opportunities =
        await opportunitiesRepository.getOpportunities(
          ruc: '', 
          search: search, 
          limit: sLimit,
          offset: sOffset
        );

    if (opportunities.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    int newOffset;
    List<Opportunity> newOpportunities;

    if (isRefresh) {
      newOffset = 0;
      newOpportunities = opportunities;
    } else {
      newOffset = state.offset + 10;
      newOpportunities = [...state.opportunities, ...opportunities];
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: newOffset,
        //opportunities: [...state.opportunities, ...opportunities]);
        opportunities: newOpportunities
    );
  }

  Future loadStatusOpportunity() async {
    if (state.isLoadingStatus) return;

    state = state.copyWith(isLoadingStatus: true);

    final statusOpportunitiy =
        await opportunitiesRepository.getStatusOpportunityByPeriod();

    if (statusOpportunitiy.isEmpty) {
      state = state.copyWith(isLoadingStatus: false);
      return;
    }

    state = state.copyWith(
        isLoadingStatus: false,
        statusOpportunity: statusOpportunitiy
    );
  }
}

class OpportunitiesState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final bool isLoadingStatus;
  final List<Opportunity> opportunities;
  final List<StatusOpportunity> statusOpportunity;
  final bool isActiveSearch;
  final String textSearch;

  OpportunitiesState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isLoadingStatus = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.statusOpportunity = const [],
      this.opportunities = const []});

  OpportunitiesState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isLoadingStatus,
    List<Opportunity>? opportunities,
    List<StatusOpportunity>? statusOpportunity,
    bool? isActiveSearch,
    String? textSearch,
  }) =>
      OpportunitiesState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
        opportunities: opportunities ?? this.opportunities,
        statusOpportunity: statusOpportunity ?? this.statusOpportunity,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
        textSearch: textSearch ?? this.textSearch,
      );
}

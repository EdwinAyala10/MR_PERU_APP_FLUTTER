import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';

import 'opportunities_repository_provider.dart';

final opportunitiesProvider =
    StateNotifierProvider<OpportunitiesNotifier, OpportunitiesState>((ref) {
  final opportunitiesRepository = ref.watch(opportunitiesRepositoryProvider);
  return OpportunitiesNotifier(opportunitiesRepository: opportunitiesRepository);
});

class OpportunitiesNotifier extends StateNotifier<OpportunitiesState> {
  final OpportunitiesRepository opportunitiesRepository;

  OpportunitiesNotifier({required this.opportunitiesRepository})
      : super(OpportunitiesState()) {
    loadNextPage();
  }

  Future<CreateUpdateOpportunityResponse> createOrUpdateOpportunity(
      Map<dynamic, dynamic> opportunityLike) async {
    try {
      final opportunityResponse =
          await opportunitiesRepository.createUpdateOpportunity(opportunityLike);

      final message = opportunityResponse.message;

      if (opportunityResponse.status) {

        final opportunity = opportunityResponse.opportunity as Opportunity;
        final isOpportunityInList =
            state.opportunities.any((element) => element.id == opportunity.id);

        if (!isOpportunityInList) {
          state = state.copyWith(opportunities: [...state.opportunities, opportunity]);
          return CreateUpdateOpportunityResponse(response: true, message: message);
        }

        state = state.copyWith(
            opportunities: state.opportunities
                .map(
                  (element) => (element.id == opportunity.id) ? opportunity : element,
                )
                .toList());

        return CreateUpdateOpportunityResponse(response: true, message: message);
      }

      return CreateUpdateOpportunityResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateOpportunityResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final opportunities = await opportunitiesRepository.getOpportunities();

    if (opportunities.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        opportunities: [...state.opportunities, ...opportunities]);
  }
}

class OpportunitiesState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Opportunity> opportunities;

  OpportunitiesState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.opportunities = const []});

  OpportunitiesState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Opportunity>? opportunities,
  }) =>
      OpportunitiesState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        opportunities: opportunities ?? this.opportunities,
      );
}

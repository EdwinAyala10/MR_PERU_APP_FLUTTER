import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';

import '../../domain/entities/status_opportunity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

import 'opportunities_repository_provider.dart';

final rucOpportunitieProvider = StateProvider<String?>((ref) => null);
final idOportunidadMotivo = StateProvider<String?>((ref) => null);
final razonOportunityProvider = StateProvider<String?>((ref) => null);

final opportunitiesProvider =
    StateNotifierProvider<OpportunitiesNotifier, OpportunitiesState>((ref) {
  final opportunitiesRepository = ref.watch(opportunitiesRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return OpportunitiesNotifier(
    opportunitiesRepository: opportunitiesRepository,
    user: user!,
  );
});

class OpportunitiesNotifier extends StateNotifier<OpportunitiesState> {
  final OpportunitiesRepository opportunitiesRepository;
  final User user;

  OpportunitiesNotifier({
    required this.opportunitiesRepository,
    required this.user,
  }) : super(OpportunitiesState()) {
    loadNextPage(isRefresh: true);
  }

  Future<CreateUpdateOpportunityResponse> createOrUpdateOpportunity(
      Map<dynamic, dynamic> opportunityLike) async {
    try {
      final opportunityResponse = await opportunitiesRepository
          .createUpdateOpportunity(opportunityLike);

      final message = opportunityResponse.message;

      if (opportunityResponse.status) {
        final opportunity = opportunityResponse.opportunity as Opportunity;

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
            response: true, message: message, id: opportunity.oprtRuc);
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

  void onChangeNotIsActiveSearchSinRefresh() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
    //loadNextPage(isRefresh: true);
    //}
  }

  Future loadNextPage({bool isRefresh = false}) async {
    final search = state.textSearch;

    if (isRefresh) {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);
    } else {
      if (state.isReload || state.isLastPage) return;
      state = state.copyWith(isReload: true);
    }

    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    } else {
      sOffset = state.offset + 10;
    }

    final opportunities = await opportunitiesRepository.getListOpportunities(
      ruc: '',
      search: search,
      limit: sLimit,
      offset: sOffset,
      idUsuario: user.code,
      estado: state.typeOpportunity,
    );

    if (opportunities.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true);
      //state = state.copyWith(isLoading: false);

      if (isRefresh) {
        state = state.copyWith(isLoading: false, isLastPage: true);
      } else {
        state = state.copyWith(isReload: false, isLastPage: true);
      }

      return;
    } else {
      int newOffset;
      List<Opportunity> newOpportunities;

      if (isRefresh) {
        newOffset = 0;
        newOpportunities = opportunities;
      } else {
        newOffset = sOffset;
        newOpportunities = [...state.opportunities, ...opportunities];
      }

      if (isRefresh) {
        state = state.copyWith(
            isLastPage: false,
            isLoading: false,
            offset: newOffset,
            //opportunities: [...state.opportunities, ...opportunities]);
            opportunities: newOpportunities);
      } else {
        state = state.copyWith(
            isLastPage: false,
            isReload: false,
            offset: newOffset,
            //opportunities: [...state.opportunities, ...opportunities]);
            opportunities: newOpportunities);
      }
    }
  }

  /// This methos is copy of loadNextPage refactor after
  Future loadFiltersOpportunity({
    bool isRefresh = false,
    String? startDate = '',
    String? startPercent = '',
    String? startValue = '',
    String? endDate = '',
    String? endPercent = '',
    String? endValue = '',
    String? status = '',
  }) async {
    final search = state.textSearch;
    if (isRefresh) {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);
    } else {
      if (state.isReload || state.isLastPage) return;
      state = state.copyWith(isReload: true);
    }
    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    } else {
      sOffset = state.offset + 10;
    }

    final opportunities = await opportunitiesRepository.getListOpportunities(
      ruc: '',
      search: search,
      limit: sLimit,
      offset: sOffset,
      idUsuario: user.code,
      estado: status ?? '',
      endDate: endDate ?? '',
      endPercent: endPercent ?? '',
      endValue: endValue ?? '',
      startDate: startDate ?? '',
      startPercent: startPercent ?? '',
      startValue: startValue ?? '',
    );

    if (opportunities.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true);
      //state = state.copyWith(isLoading: false);

      if (isRefresh) {
        state = state.copyWith(isLoading: false, isLastPage: true);
      } else {
        state = state.copyWith(isReload: false, isLastPage: true);
      }

      return;
    } else {
      int newOffset;
      List<Opportunity> newOpportunities;

      if (isRefresh) {
        newOffset = 0;
        newOpportunities = opportunities;
      } else {
        newOffset = sOffset;
        newOpportunities = [...state.opportunities, ...opportunities];
      }

      if (isRefresh) {
        state = state.copyWith(
            isLastPage: false,
            isLoading: false,
            offset: newOffset,
            //opportunities: [...state.opportunities, ...opportunities]);
            opportunities: newOpportunities);
      } else {
        state = state.copyWith(
            isLastPage: false,
            isReload: false,
            offset: newOffset,
            //opportunities: [...state.opportunities, ...opportunities]);
            opportunities: newOpportunities);
      }
    }
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
        isLoadingStatus: false, statusOpportunity: statusOpportunitiy);
  }

  void updateTypeOpportunity(String type) {
    state = state.copyWith(typeOpportunity: type);
  }
}

class OpportunitiesState {
  final bool isLastPage;
  final bool isReload;
  final int limit;
  final int offset;
  final bool isLoading;
  final bool isLoadingStatus;
  final List<Opportunity> opportunities;
  final List<StatusOpportunity> statusOpportunity;
  final bool isActiveSearch;
  final String textSearch;
  final String typeOpportunity;

  OpportunitiesState(
      {this.isLastPage = false,
      this.isReload = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isLoadingStatus = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.typeOpportunity = '',
      this.statusOpportunity = const [],
      this.opportunities = const []});

  OpportunitiesState copyWith({
    bool? isLastPage,
    bool? isReload,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isLoadingStatus,
    List<Opportunity>? opportunities,
    List<StatusOpportunity>? statusOpportunity,
    bool? isActiveSearch,
    String? textSearch,
    String? typeOpportunity,
  }) =>
      OpportunitiesState(
        isLastPage: isLastPage ?? this.isLastPage,
        isReload: isReload ?? this.isReload,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        typeOpportunity: typeOpportunity ?? this.typeOpportunity,
        isLoading: isLoading ?? this.isLoading,
        isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
        opportunities: opportunities ?? this.opportunities,
        statusOpportunity: statusOpportunity ?? this.statusOpportunity,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
        textSearch: textSearch ?? this.textSearch,
      );
}

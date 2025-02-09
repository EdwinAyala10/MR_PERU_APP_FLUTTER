import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

import 'activities_repository_provider.dart';

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
  final activitiesRepository = ref.watch(activitiesRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return ActivitiesNotifier(activitiesRepository: activitiesRepository,
      user: user!,
  );
});

class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  final ActivitiesRepository activitiesRepository;
  final User user;

  ActivitiesNotifier({required this.activitiesRepository,
    required this.user,
  })
      : super(
          ActivitiesState(),
        ) {
    loadNextPage(isRefresh: true);
  }

  Future<CreateUpdateActivityResponse> createOrUpdateActivity(
      Map<dynamic, dynamic> activityLike) async {
    try {
      final activityResponse =
          await activitiesRepository.createUpdateActivity(activityLike);

      final message = activityResponse.message;

      if (activityResponse.status) {
        final activity = activityResponse.activity as Activity;
        /*final activity = activityResponse.activity as Activity;
        final isActivityInList =
            state.activities.any((element) => element.id == activity.id);

        if (!isActivityInList) {
          state = state.copyWith(activities: [...state.activities, activity]);
          return CreateUpdateActivityResponse(response: true, message: message);
        }

        state = state.copyWith(
            activities: state.activities
                .map(
                  (element) => (element.id == activity.id) ? activity : element,
                )
                .toList());*/

        return CreateUpdateActivityResponse(
            response: true, message: message, id: activity.actiRuc);
      }

      return CreateUpdateActivityResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateActivityResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future<void> onChangeIsActiveSearch() async {
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

    final activities = await activitiesRepository.getActivities(
        search: search, 
        limit: sLimit, 
        offset: sOffset,
        idUsuario: user.code
        );

    if (activities.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true);
      if (isRefresh) {
        state = state.copyWith(isLoading: false, isLastPage: true);    
      } else {
        state = state.copyWith(isReload: false, isLastPage: true);
      }
      return;
    } else {
      int newOffset;
      List<Activity> newActivities;

      if (isRefresh) {
        newOffset = 0;
        newActivities = activities;
      } else {
        newOffset = sOffset;
        newActivities = [...state.activities, ...activities];
      }

      if (isRefresh) {
        state = state.copyWith(
          isLastPage: false,
          isLoading: false,
          offset: newOffset,
          //activities: [...state.activities, ...activities]
          activities: newActivities);
      } else {
        state = state.copyWith(
          isLastPage: false,
          isReload: false,
          offset: newOffset,
          //activities: [...state.activities, ...activities]
          activities: newActivities);
      }

      
    }

  }

  Future<void> onDeleteState()async{
    state = state.copyWith(
      isLoading: true,
      activities: [],
    );
  }

  Future loadNextPageActivitiesByOpportunities({
    bool isRefresh = false,
    required String opportunityId,
  }) async {
    final search = state.textSearch;
    state = state.copyWith(
      isActiveSearch: false,
      textSearch: '',
      offset: 0,
      activities: [],
    );
    //if (state.isLoading || state.isLastPage) return;
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    }

    final activities = await activitiesRepository.getActivitiesByOpportunitie(
      search: search,
      limit: sLimit,
      offset: sOffset,
      opportunityId: opportunityId,
    );

    if (activities.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true);
      state = state.copyWith(isLoading: false);
      return;
    }

    int newOffset;
    List<Activity> newActivities;

    if (isRefresh) {
      newOffset = 0;
      newActivities = activities;
    } else {
      newOffset = state.offset + 10;
      newActivities = [...state.activities, ...activities];
    }

    state = state.copyWith(
        //isLastPage: false,
        isLoading: false,
        offset: newOffset,
        //activities: [...state.activities, ...activities]
        activities: newActivities);
  }
}

class ActivitiesState {
  final bool isLastPage;
  final bool isReload;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Activity> activities;
  final bool isActiveSearch;
  final String textSearch;

  ActivitiesState(
      {this.isLastPage = false,
      this.isReload = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.activities = const []});

  ActivitiesState copyWith({
    bool? isLastPage,
    bool? isReload,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isActiveSearch,
    String? textSearch,
    List<Activity>? activities,
  }) =>
      ActivitiesState(
        isLastPage: isLastPage ?? this.isLastPage,
        isReload: isReload ?? this.isReload,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        activities: activities ?? this.activities,
        textSearch: textSearch ?? this.textSearch,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
      );
}

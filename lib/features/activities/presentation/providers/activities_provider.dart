import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/activities/domain/domain.dart';

import 'activities_repository_provider.dart';

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
  final activitiesRepository = ref.watch(activitiesRepositoryProvider);
  return ActivitiesNotifier(activitiesRepository: activitiesRepository);
});

class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  final ActivitiesRepository activitiesRepository;

  ActivitiesNotifier({required this.activitiesRepository})
      : super(ActivitiesState()) {
    loadNextPage();
  }

  Future<CreateUpdateActivityResponse> createOrUpdateActivity(
      Map<dynamic, dynamic> activityLike) async {
    try {
      final activityResponse =
          await activitiesRepository.createUpdateActivity(activityLike);

      final message = activityResponse.message;

      if (activityResponse.status) {

        final activity = activityResponse.activity as Activity;
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
                .toList());

        return CreateUpdateActivityResponse(response: true, message: message);
      }

      return CreateUpdateActivityResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateActivityResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final activities = await activitiesRepository.getActivities();

    if (activities.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        activities: [...state.activities, ...activities]);
  }
}

class ActivitiesState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Activity> activities;

  ActivitiesState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.activities = const []});

  ActivitiesState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Activity>? activities,
  }) =>
      ActivitiesState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        activities: activities ?? this.activities,
      );
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/agenda/domain/domain.dart';

import 'events_repository_provider.dart';

final eventsProvider =
    StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final eventsRepository = ref.watch(eventsRepositoryProvider);
  return EventsNotifier(eventsRepository: eventsRepository);
});

class EventsNotifier extends StateNotifier<EventsState> {
  final EventsRepository eventsRepository;

  EventsNotifier({required this.eventsRepository})
      : super(EventsState()) {
    loadNextPage();
  }

  Future<CreateUpdateEventResponse> createOrUpdateEvent(
      Map<dynamic, dynamic> eventLike) async {
    try {
      final eventResponse =
          await eventsRepository.createUpdateEvent(eventLike);

      final message = eventResponse.message;

      if (eventResponse.status) {

        final event = eventResponse.event as Event;
        final isEventInList =
            state.events.any((element) => element.id == event.id);

        if (!isEventInList) {
          state = state.copyWith(events: [...state.events, event]);
          return CreateUpdateEventResponse(response: true, message: message);
        }

        state = state.copyWith(
            events: state.events
                .map(
                  (element) => (element.id == event.id) ? event : element,
                )
                .toList());

        return CreateUpdateEventResponse(response: true, message: message);
      }

      return CreateUpdateEventResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateEventResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final events = await eventsRepository.getEvents();

    if (events.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        events: [...state.events, ...events]);
  }
}

class EventsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Event> events;

  EventsState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.events = const []});

  EventsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Event>? events,
  }) =>
      EventsState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        events: events ?? this.events,
      );
}

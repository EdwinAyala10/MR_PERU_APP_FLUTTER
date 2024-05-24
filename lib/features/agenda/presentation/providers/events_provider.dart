import 'dart:collection';

import '../widgets/add_event_not_exist.dart';
import '../widgets/exist_event.dart';
import '../widgets/replace_event_exist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

import 'events_repository_provider.dart';

final eventsProvider =
    StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final eventsRepository = ref.watch(eventsRepositoryProvider);
  return EventsNotifier(eventsRepository: eventsRepository);
});

class EventsNotifier extends StateNotifier<EventsState> {
  final EventsRepository eventsRepository;

  EventsNotifier({required this.eventsRepository}) : super(EventsState()) {
    loadNextPage();
  }

  Future<CreateUpdateEventResponse> createOrUpdateEvent(
      Map<dynamic, dynamic> eventLike) async {
    try {
      final eventResponse = await eventsRepository.createUpdateEvent(eventLike);

      final message = eventResponse.message;

      if (eventResponse.status) {
        final event = eventResponse.event as Event;

        print('ASUNTO: ${event.evntAsunto}');

        final isEventInList = eventItExist(state.linkedEvents, event.id);

        if (!isEventInList) {
          final linkedEvents = addEventIfNotExist(state.linkedEvents, event);
          state = state.copyWith(linkedEvents: linkedEvents, focusedDay: event.evntFechaInicioEvento);
          return CreateUpdateEventResponse(response: true, message: message);
        }

        final linkedEvents = replaceEventExist(state.linkedEvents, event);
        state = state.copyWith(linkedEvents: linkedEvents, focusedDay: event.evntFechaInicioEvento);

    
        /*
        final isEventInList = state.events.any((element) => element.id == event.id);


        if (!isEventInList) {
          state = state.copyWith(events: [...state.events, event]);
          return CreateUpdateEventResponse(response: true, message: message);
        }

        state = state.copyWith(
            events: state.events
                .map(
                  (element) => (element.id == event.id) ? event : element,
                )
                .toList());*/

        return CreateUpdateEventResponse(response: true, message: message);
      }

      return CreateUpdateEventResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateEventResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future onChangeSelectedDay(DateTime date) async {
    state = state.copyWith(selectedDay: date);
  }

  Future onChangeFocusedDay(DateTime date) async {
    state = state.copyWith(focusedDay: date);
  }

  Future onSelectedEvents(DateTime date) async {
    state = state.copyWith(
        selectedEvents:
            state.linkedEvents[DateTime(date.year, date.month, date.day)] ??
                []);
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final linkedEvents = await eventsRepository.getEvents();
    final linkedEventsList = await eventsRepository.getEventsList();

    if (linkedEvents.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        linkedEventsList:  linkedEventsList,
        //linkedEvents: [...state.linkedEvents, ...linkedEvents]
        linkedEvents: LinkedHashMap.from(state.linkedEvents)
          ..addAll(linkedEvents));
  }
}

class EventsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Event> events;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final List<Event> selectedEvents;
  final LinkedHashMap<DateTime, List<Event>> linkedEvents;
  final List<Event> linkedEventsList;

  EventsState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.events = const [],
      this.selectedEvents = const [],
      this.linkedEventsList = const [],
      DateTime? selectedDay,
      DateTime? focusedDay,
      LinkedHashMap<DateTime, List<Event>>? linkedEvents})
      : this.selectedDay = selectedDay ?? DateTime.now(),
        this.focusedDay = focusedDay ?? DateTime.now(),
        linkedEvents = linkedEvents ?? LinkedHashMap<DateTime, List<Event>>();

  EventsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Event>? events,
    List<Event>? selectedEvents,
    DateTime? selectedDay,
    DateTime? focusedDay,
    LinkedHashMap<DateTime, List<Event>>? linkedEvents,
    List<Event>? linkedEventsList,
  }) =>
      EventsState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        events: events ?? this.events,
        selectedEvents: selectedEvents ?? this.selectedEvents,
        linkedEventsList: linkedEventsList ?? this.linkedEventsList,
        selectedDay: selectedDay ?? this.selectedDay,
        focusedDay: focusedDay ?? this.focusedDay,
        linkedEvents: linkedEvents ?? this.linkedEvents,
      );
}

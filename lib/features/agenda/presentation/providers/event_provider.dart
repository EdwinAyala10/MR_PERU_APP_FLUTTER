import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:intl/intl.dart';

import 'events_repository_provider.dart';

final eventProvider = StateNotifierProvider.autoDispose
    .family<EventNotifier, EventState, String>((ref, id) {
  final eventsRepository = ref.watch(eventsRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return EventNotifier(eventsRepository: eventsRepository, user: user!, id: id);
});

class EventNotifier extends StateNotifier<EventState> {
  final EventsRepository eventsRepository;
  final User user;

  EventNotifier({
    required this.eventsRepository,
    required this.user,
    required String id,
  }) : super(EventState(id: id)) {
    loadEvent();
  }

  Event newEmptyEvent() {
    print('NEW EMPTY EVENT');
    print(user.code);
    print(user.name);

    return Event(
      id: 'new',

      evntAsunto: '',
      evntComentario: '',
      evntIdEventoIn: '',
      evntCorreosExternos: '',
      evntHoraFinEvento: DateFormat('HH:mm:ss')
          .format(DateTime.now().add(const Duration(minutes: 30))),
      evntFechaFinEvento: DateTime.now(),
      evntDireccionMapa: '',
      evntCoordenadaLatitud: '',
      evntCoordenadaLongitud: '',
      evntFechaInicioEvento: DateTime.now(),
      evntHoraInicioEvento: DateFormat('HH:mm:ss').format(DateTime.now()),
      evntHoraRecordatorio: '',
      evntIdOportunidad: '',
      evntIdRecordatorio: 1,
      evntIdTipoGestion: '',
      evntUbigeo: '',
      evntNombreOportunidad: '',
      evntIdUsuarioRegistro: user.code,
      evntIdUsuarioResponsable: user.code,
      evntNombreUsuarioResponsable: user.name,
      evntNombreTipoGestion: '',
      evntRuc: '',
      arraycontacto: [],
      arraycontactoElimimar: [],
      todoDia: '0',
      opt: '',
    );
  }

  Future<void> loadEvent() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          event: newEmptyEvent(),
        );

        return;
      }

      final event = await eventsRepository.getEventById(state.id);

      state = state.copyWith(isLoading: false, event: event);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class EventState {
  final String id;
  final Event? event;
  final bool isLoading;
  final bool isSaving;

  EventState({
    required this.id,
    this.event,
    this.isLoading = true,
    this.isSaving = false,
  });

  EventState copyWith({
    String? id,
    Event? event,
    bool? isLoading,
    bool? isSaving,
  }) =>
      EventState(
        id: id ?? this.id,
        event: event ?? this.event,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

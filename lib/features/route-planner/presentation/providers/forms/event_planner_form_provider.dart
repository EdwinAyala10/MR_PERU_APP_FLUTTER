import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/domain/entities/create_event_planner_response.dart';
import 'package:crm_app/features/route-planner/domain/entities/evento_planificador_ruta_array.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

import '../../../../shared/shared.dart';

final eventPlannerFormProvider =
    StateNotifierProvider<EventPlannerFormNotifier, EventPlannerFormState>(
        (ref) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createCallback =
      ref.watch(routePlannerProvider.notifier).createEventPlanner;

  //final totalDistanceA = ref.watch(mapProvider).totalDistance;
  //final totalDurationA = ref.watch(mapProvider).totalDuration;

  final user = ref.watch(authProvider).user;

  return EventPlannerFormNotifier(
    user: user!,
    onSubmitCallback: createCallback,
    // totalDistance: totalDistanceA,
    // totalDuration: totalDurationA
  );
});

class EventPlannerFormNotifier extends StateNotifier<EventPlannerFormState> {
  final Future<CreateEventPlannerResponse> Function(
      Map<dynamic, dynamic> eventLike)? onSubmitCallback;
  final User user;
  //final int totalDistance;
  //final int totalDuration;

  EventPlannerFormNotifier({
    this.onSubmitCallback,
    //this.totalDistance = 0,
    //this.totalDuration = 0,
    required this.user,
  }) : super(EventPlannerFormState());

  Future<CreateEventPlannerResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateEventPlannerResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateEventPlannerResponse(response: false, message: '');
    }

    print('LLEGO AQUI');
    //print('strDistancia: ${totalDistance}');
    //print('strDuration: ${totalDuration}');
    //String strDistance = formatDistanceV2(totalDistance);
    //String strDuration = formatTimeFromSeconds(totalDuration);

    final eventLike = {
      //'EVNT_ASUNTO': state.evntAsunto,
      'PLRT_FECHA_INICIO':
          "${state.evntFechaInicioEvento?.year.toString().padLeft(4, '0')}-${state.evntFechaInicioEvento?.month.toString().padLeft(2, '0')}-${state.evntFechaInicioEvento?.day.toString().padLeft(2, '0')}",
      'PLRT_FECHA_FIN':
          "${state.evntFechaTerminoEvento?.year.toString().padLeft(4, '0')}-${state.evntFechaTerminoEvento?.month.toString().padLeft(2, '0')}-${state.evntFechaTerminoEvento?.day.toString().padLeft(2, '0')}",
      'PLRT_HORA_INICIO': state.evntHoraInicioEvento,
      'EVNT_ID_TIPO_GESTION': state.evntIdTipoGestion.value,
      'PLRT_ID_HORARIO_TRABAJO': state.horarioTrabajoId,
      'PLRT_ID_TIEMPO_ENTRE_VISITAS': state.tiempoEntreVisitasId.value,
      'PLRT_ID_TIEMPO_DE_VISTA': state.evntIdIntervaloReunion.value,
      //'EVNT_ID_RECORDATORIO': state.evntIdRecordatorio,
      //'ID_INTERVALO_REUNION': state.evntIdIntervaloReunion.value,
      'PLRT_TIEMPO_RUTA': state.tiempoRuta,
      'PLRT_DISTANCIA_RUTA': state.distanciaRuta,
      'PLRT_ID_USUARIO_RESPONSABLE': state.plrtIdUsuarioResponsable,
      'EVNT_ID_USUARIO_RESPONSABLE': state.evntIdUsuarioResponsable,
      //'EVNT_NOMBRE_USUARIO_RESPONSABLE': state.evntNombreUsuarioResponsable,
      'EVENTOS_PLANIFICADOR_RUTA': state.arrayEventosPlanificadorRuta != null
          ? List<dynamic>.from(
              state.arrayEventosPlanificadorRuta!.map((x) => x.toJson()))
          : [],
    };

    try {
      return await onSubmitCallback!(eventLike);
    } catch (e) {
      return CreateEventPlannerResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        TipoGestion.dirty(state.evntIdTipoGestion.value),
        Select.dirty(state.evntIdIntervaloReunion.value),
      ]),
    );
  }

  void onUpdateUserPlannerSelector(String value) {
    state = state.copyWith(
      plrtIdUsuarioResponsable: value,
    );
  }

  void setInitialForm() {
    state = state.copyWith(
      id: '0',
      //evntAsunto: 'evento planificación de ruta',
      evntFechaInicioEvento: DateTime.now(),
      evntFechaTerminoEvento: DateTime.now(),
      evntHoraInicioEvento: DateFormat('HH:mm:ss').format(DateTime.now()),
      evntIdTipoGestion: const TipoGestion.dirty('04'),
      tiempoEntreVisitasId: const HoraEntreVisita.dirty(''),
      //evntIdRecordatorio: 1,
      evntIdIntervaloReunion: const Select.dirty(''),
      evntIdUsuarioResponsable: user.code,
      evntNombreUsuarioResponsable: user.name,
      arrayEventosPlanificadorRuta: [],
    );
  }

  Future<void> onChangeHorarioTrabajo(
      String id, String name, String duracion, String distancia) async {
    print('llego a onChangeHorarioTrabajo');

    print('id: ${id}');
    print('name: ${name}');
    print('duracion: ${duracion}');
    print('distancia: ${distancia}');

    state = state.copyWith(
        horarioTrabajoId: id,
        horarioTrabajoNombre: name,
        tiempoRuta: duracion,
        distanciaRuta: distancia);
  }

  void onTipoGestionChanged(String id, String name) {
    state = state.copyWith(
        evntIdTipoGestion: TipoGestion.dirty(id),
        evntNombreTipoGestion: name,
        isFormValid: Formz.validate([
          TipoGestion.dirty(id),
          Select.dirty(state.evntIdIntervaloReunion.value),
          HoraEntreVisita.dirty(state.tiempoEntreVisitasId.value)
        ]));
  }

  void onTiempoReunionesChanged(String id, String name) {
    //state = state.copyWith(evntIdRecordatorio: id, evntNombreRecordatorio: name);
    state = state.copyWith(
        evntIdIntervaloReunion: Select.dirty(id),
        evntNombreIntervaloReunion: name,
        isFormValid: Formz.validate([
          TipoGestion.dirty(state.evntIdTipoGestion.value),
          Select.dirty(id),
          HoraEntreVisita.dirty(state.tiempoEntreVisitasId.value)
        ]));
  }

  void onTiempoEntreVisitaChanged(String id, String name) {
    //state = state.copyWith(evntIdRecordatorio: id, evntNombreRecordatorio: name);
    state = state.copyWith(
        tiempoEntreVisitasId: HoraEntreVisita.dirty(id),
        tiempoEntreVisitasNombre: name,
        isFormValid: Formz.validate([
          TipoGestion.dirty(state.evntIdTipoGestion.value),
          Select.dirty(state.evntIdIntervaloReunion.value),
          HoraEntreVisita.dirty(id)
        ]));
  }

  void onFechaChanged(DateTime fecha) {
    state = state.copyWith(evntFechaInicioEvento: fecha);
  }

  void onFechaTerminoChanged(DateTime fecha) {
    state = state.copyWith(evntFechaTerminoEvento: fecha);
  }

  void onHoraInicioChanged(String hora) {
    state = state.copyWith(evntHoraInicioEvento: hora);
  }

  void onDurationAndDistanceChanged(String tiempo, String distancia) {
    state = state.copyWith(tiempoRuta: tiempo, distanciaRuta: distancia);
  }

  Future<void> setLocalesArray(
      List<CompanyLocalRoutePlanner> localesSelected) async {
    List<EventoPlanificadorRutaArray> newArrayEventosPlanificadorRuta = [];

    for (var i = 0; i < localesSelected.length; i++) {
      final local = localesSelected[i];
      final item = EventoPlanificadorRutaArray(
          evntRuc: local.ruc, evntLocalCodigo: int.parse(local.localCodigo));
      newArrayEventosPlanificadorRuta.add(item);
    }

    state = state.copyWith(
        arrayEventosPlanificadorRuta: newArrayEventosPlanificadorRuta);
  }
}

class EventPlannerFormState {
  final bool isFormValid;
  final String? id;

  //final String? evntAsunto;
  final DateTime? evntFechaInicioEvento;
  final DateTime? evntFechaTerminoEvento;
  final String? evntHoraInicioEvento;
  final TipoGestion evntIdTipoGestion;
  final String? evntNombreTipoGestion;
  //final int? evntIdRecordatorio;
  final Select evntIdIntervaloReunion;
  final String? evntNombreIntervaloReunion;
  final String? evntNombreRecordatorio;
  final String? evntIdUsuarioResponsable;
  final String? evntNombreUsuarioResponsable;
  final List<EventoPlanificadorRutaArray> arrayEventosPlanificadorRuta;

  final String? horarioTrabajoNombre;
  final String? horarioTrabajoId;
  final HoraEntreVisita tiempoEntreVisitasId;
  final String? tiempoEntreVisitasNombre;
  final String? tiempoRuta;
  final String? distanciaRuta;

  final String? plrtIdUsuarioResponsable;

  EventPlannerFormState({
    this.isFormValid = false,
    this.plrtIdUsuarioResponsable,
    this.id,
    //this.evntAsunto = '',
    this.evntFechaInicioEvento,
    this.evntFechaTerminoEvento,
    this.evntHoraInicioEvento = '',
    this.evntIdTipoGestion = const TipoGestion.dirty(''),
    this.evntNombreTipoGestion = '',
    //this.evntIdRecordatorio,
    this.evntIdIntervaloReunion = const Select.dirty(''),
    this.evntNombreIntervaloReunion = '',
    this.evntNombreRecordatorio,
    this.evntIdUsuarioResponsable,
    this.horarioTrabajoNombre,
    this.horarioTrabajoId,
    this.tiempoEntreVisitasId = const HoraEntreVisita.dirty(''),
    this.tiempoEntreVisitasNombre,
    this.evntNombreUsuarioResponsable,
    this.arrayEventosPlanificadorRuta = const [],
    this.tiempoRuta,
    this.distanciaRuta,
  });

  EventPlannerFormState copyWith({
    bool? isFormValid,
    String? id,
    //String? evntAsunto,
    DateTime? evntFechaInicioEvento,
    DateTime? evntFechaTerminoEvento,
    String? evntHoraInicioEvento,
    TipoGestion? evntIdTipoGestion,
    String? evntNombreTipoGestion,
    //int? evntIdRecordatorio,
    Select? evntIdIntervaloReunion,
    String? evntNombreIntervaloReunion,
    String? evntNombreRecordatorio,
    String? evntIdUsuarioResponsable,
    String? evntNombreUsuarioResponsable,
    String? horarioTrabajoNombre,
    String? plrtIdUsuarioResponsable,
    String? horarioTrabajoId,
    HoraEntreVisita? tiempoEntreVisitasId,
    String? tiempoEntreVisitasNombre,
    String? tiempoRuta,
    String? distanciaRuta,
    List<EventoPlanificadorRutaArray>? arrayEventosPlanificadorRuta,
  }) =>
      EventPlannerFormState(
        plrtIdUsuarioResponsable:
            plrtIdUsuarioResponsable ?? this.plrtIdUsuarioResponsable,
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        //evntAsunto: evntAsunto ?? this.evntAsunto,
        evntFechaInicioEvento:
            evntFechaInicioEvento ?? this.evntFechaInicioEvento,
        evntFechaTerminoEvento:
            evntFechaTerminoEvento ?? this.evntFechaTerminoEvento,
        evntHoraInicioEvento: evntHoraInicioEvento ?? this.evntHoraInicioEvento,
        evntIdTipoGestion: evntIdTipoGestion ?? this.evntIdTipoGestion,
        evntNombreTipoGestion:
            evntNombreTipoGestion ?? this.evntNombreTipoGestion,
        //evntIdRecordatorio: evntIdRecordatorio ?? this.evntIdRecordatorio,
        evntIdIntervaloReunion:
            evntIdIntervaloReunion ?? this.evntIdIntervaloReunion,
        evntNombreIntervaloReunion:
            evntNombreIntervaloReunion ?? this.evntNombreIntervaloReunion,
        evntNombreRecordatorio:
            evntNombreRecordatorio ?? this.evntNombreRecordatorio,

        horarioTrabajoNombre: horarioTrabajoNombre ?? this.horarioTrabajoNombre,
        horarioTrabajoId: horarioTrabajoId ?? this.horarioTrabajoId,
        tiempoEntreVisitasId: tiempoEntreVisitasId ?? this.tiempoEntreVisitasId,
        tiempoEntreVisitasNombre:
            tiempoEntreVisitasNombre ?? this.tiempoEntreVisitasNombre,

        evntIdUsuarioResponsable:
            evntIdUsuarioResponsable ?? this.evntIdUsuarioResponsable,
        evntNombreUsuarioResponsable:
            evntNombreUsuarioResponsable ?? this.evntNombreUsuarioResponsable,
        arrayEventosPlanificadorRuta:
            arrayEventosPlanificadorRuta ?? this.arrayEventosPlanificadorRuta,
        tiempoRuta: tiempoRuta ?? this.tiempoRuta,
        distanciaRuta: distanciaRuta ?? this.distanciaRuta,
      );
}

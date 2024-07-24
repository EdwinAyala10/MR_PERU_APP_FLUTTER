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

final eventPlannerFormProvider = StateNotifierProvider<EventPlannerFormNotifier, EventPlannerFormState>((ref) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createCallback =
      ref.watch(routePlannerProvider.notifier).createEventPlanner;

  final user = ref.watch(authProvider).user;

  return EventPlannerFormNotifier(
    user: user!, 
    onSubmitCallback: createCallback,
  );
});

class EventPlannerFormNotifier extends StateNotifier<EventPlannerFormState> {
  final Future<CreateEventPlannerResponse> Function(
      Map<dynamic, dynamic> eventLike)? onSubmitCallback;
  final User user;

  EventPlannerFormNotifier({
    this.onSubmitCallback,
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

    final eventLike = {
      //'EVNT_ASUNTO': state.evntAsunto,
      'EVNT_FECHA_INICIO_EVENTO':
          "${state.evntFechaInicioEvento?.year.toString().padLeft(4, '0')}-${state.evntFechaInicioEvento?.month.toString().padLeft(2, '0')}-${state.evntFechaInicioEvento?.day.toString().padLeft(2, '0')}",
      'EVNT_HORA_INICIO_EVENTO': state.evntHoraInicioEvento,
      'EVNT_ID_TIPO_GESTION': state.evntIdTipoGestion.value,
      //'EVNT_ID_RECORDATORIO': state.evntIdRecordatorio,
      'ID_INTERVALO_REUNION': state.evntIdIntervaloReunion.value,
      'EVNT_ID_USUARIO_RESPONSABLE': state.evntIdUsuarioResponsable,
      'EVNT_NOMBRE_USUARIO_RESPONSABLE': state.evntNombreUsuarioResponsable,
      'EVENTOS_PLANIFICADOR_RUTA': state.arrayEventosPlanificadorRuta != null
          ? List<dynamic>.from(state.arrayEventosPlanificadorRuta!.map((x) => x.toJson()))
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
        Select.dirty(state.evntIdTipoGestion.value),
        Select.dirty(state.evntIdIntervaloReunion.value),
      ]),
    );
  }

  void setInitialForm() {
    state = state.copyWith(
      id: '0',
      //evntAsunto: 'evento planificación de ruta',
      evntFechaInicioEvento: DateTime.now(),
      evntHoraInicioEvento: DateFormat('HH:mm:ss').format(DateTime.now()),
      evntIdTipoGestion: const TipoGestion.dirty('04'),
      //evntIdRecordatorio: 1,
      evntIdIntervaloReunion: const Select.dirty(''),
      evntIdUsuarioResponsable: user.code,
      evntNombreUsuarioResponsable: user.name,
      arrayEventosPlanificadorRuta: [],
    );
  }

  void onTipoGestionChanged(String id, String name) {
    state = state.copyWith(
      evntIdTipoGestion: TipoGestion.dirty(id),
      evntNombreTipoGestion: name,
      isFormValid: Formz.validate([
        TipoGestion.dirty(id),
        Select.dirty(state.evntIdIntervaloReunion.value),
      ]));
  }

  void onTiempoReunionesChanged(String id, String name) {
    //state = state.copyWith(evntIdRecordatorio: id, evntNombreRecordatorio: name);
    state = state.copyWith(
      evntIdIntervaloReunion: Select.dirty(id),
      evntNombreIntervaloReunion: name,
      isFormValid: Formz.validate([
        TipoGestion.dirty(id),
        Select.dirty(state.evntIdTipoGestion.value),
      ]));
  }

  void onFechaChanged(DateTime fecha) {
    state =
        state.copyWith(evntFechaInicioEvento: fecha);
  }

  void onHoraInicioChanged(String hora) {
    state = state.copyWith(evntHoraInicioEvento: hora);
  }

  Future<void> setLocalesArray(List<CompanyLocalRoutePlanner> localesSelected) async {

    List<EventoPlanificadorRutaArray> newArrayEventosPlanificadorRuta = [];

    for (var i = 0; i < localesSelected.length; i++) {
      final local = localesSelected[i];
      final item = EventoPlanificadorRutaArray(evntRuc: local.ruc, evntLocalCodigo: int.parse(local.localCodigo));
      newArrayEventosPlanificadorRuta.add(item);
    }

    state = state.copyWith(
      arrayEventosPlanificadorRuta: newArrayEventosPlanificadorRuta
    );
  }

}

class EventPlannerFormState {
  final bool isFormValid;
  final String? id;

  //final String? evntAsunto;
  final DateTime? evntFechaInicioEvento;
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

  EventPlannerFormState(
      {this.isFormValid = false,
      this.id,
      //this.evntAsunto = '',
      this.evntFechaInicioEvento,
      this.evntHoraInicioEvento = '',
      this.evntIdTipoGestion = const TipoGestion.dirty(''),
      this.evntNombreTipoGestion = '',
      //this.evntIdRecordatorio,
      this.evntIdIntervaloReunion = const Select.dirty(''),
      this.evntNombreIntervaloReunion = '',
      this.evntNombreRecordatorio,
      this.evntIdUsuarioResponsable,
      this.evntNombreUsuarioResponsable,
      this.arrayEventosPlanificadorRuta = const []
      });

  EventPlannerFormState copyWith({
    bool? isFormValid,
    String? id,
    //String? evntAsunto,
    DateTime? evntFechaInicioEvento,
    String? evntHoraInicioEvento,
    TipoGestion? evntIdTipoGestion,
    String? evntNombreTipoGestion,
    //int? evntIdRecordatorio,
    Select? evntIdIntervaloReunion,
    String? evntNombreIntervaloReunion,
    String? evntNombreRecordatorio,
    String? evntIdUsuarioResponsable,
    String? evntNombreUsuarioResponsable,
    List<EventoPlanificadorRutaArray>? arrayEventosPlanificadorRuta,
  }) =>
      EventPlannerFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        //evntAsunto: evntAsunto ?? this.evntAsunto,
        evntFechaInicioEvento: evntFechaInicioEvento ?? this.evntFechaInicioEvento,
        evntHoraInicioEvento:
            evntHoraInicioEvento ?? this.evntHoraInicioEvento,
        evntIdTipoGestion:
            evntIdTipoGestion ?? this.evntIdTipoGestion,
        evntNombreTipoGestion:
            evntNombreTipoGestion ?? this.evntNombreTipoGestion,
        //evntIdRecordatorio: evntIdRecordatorio ?? this.evntIdRecordatorio,
        evntIdIntervaloReunion: evntIdIntervaloReunion ?? this.evntIdIntervaloReunion,
        evntNombreIntervaloReunion: evntNombreIntervaloReunion ?? this.evntNombreIntervaloReunion,
        evntNombreRecordatorio: evntNombreRecordatorio ?? this.evntNombreRecordatorio,
        evntIdUsuarioResponsable: evntIdUsuarioResponsable ?? this.evntIdUsuarioResponsable,
        evntNombreUsuarioResponsable: evntNombreUsuarioResponsable ?? this.evntNombreUsuarioResponsable,
        arrayEventosPlanificadorRuta: arrayEventosPlanificadorRuta ?? this.arrayEventosPlanificadorRuta,
      );
}
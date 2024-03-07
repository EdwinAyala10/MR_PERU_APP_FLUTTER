import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/domain/entities/contact_array.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/agenda/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final eventFormProvider = StateNotifierProvider.autoDispose
    .family<EventFormNotifier, EventFormState, Event>((ref, event) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(eventsProvider.notifier).createOrUpdateEvent;

  return EventFormNotifier(
    event: event,
    onSubmitCallback: createUpdateCallback,
  );
});

class EventFormNotifier extends StateNotifier<EventFormState> {
  final Future<CreateUpdateEventResponse> Function(
      Map<dynamic, dynamic> eventLike)? onSubmitCallback;

  EventFormNotifier({
    this.onSubmitCallback,
    required Event event,
  }) : super(EventFormState(
          id: event.id,
          evntAsunto: Name.dirty(event.evntAsunto),
          evntComentario: event.evntComentario ?? '',
          evntCoordenadaLatitud: event.evntCoordenadaLatitud ?? '',
          evntCoordenadaLongitud: event.evntCoordenadaLongitud ?? '',
          evntCorreosExternos: event.evntCorreosExternos ?? '',
          evntDireccionMapa: event.evntDireccionMapa ?? '',
          evntIdTipoGestion: event.evntIdTipoGestion ?? '',
          evntFechaFinEvento: event.evntFechaFinEvento ?? DateTime.now(),
          evntFechaInicioEvento: event.evntFechaInicioEvento ?? DateTime.now(),
          evntHoraFinEvento: event.evntHoraFinEvento ?? '',
          evntHoraInicioEvento: event.evntHoraInicioEvento ?? '',
          evntHoraRecordatorio: event.evntHoraFinEvento ?? '',
          evntIdEventoIn: event.evntIdEventoIn ?? '',
          evntIdOportunidad: event.evntIdOportunidad ?? '',
          evntIdRecordatorio: event.evntIdRecordatorio ?? 1,
          evntNombreRecordatorio: event.evntNombreRecordatorio ?? '',
          evntIdUsuarioRegistro: event.evntIdUsuarioRegistro ?? '',
          evntIdUsuarioResponsable: event.evntIdUsuarioResponsable ?? '',
          evntNombreUsuarioResponsable:
              event.evntNombreUsuarioResponsable ?? '',
          evntNombreOportunidad: event.evntNombreOportunidad ?? '',
          evntNombreTipoGestion: event.evntNombreTipoGestion ?? '',
          evntRazon: event.evntRazon ?? '',
          todoDia: event.todoDia ?? '0',
          evntRuc: event.evntRuc ?? '',
          evntUbigeo: event.evntUbigeo ?? '',
          opt: event.opt ?? '',
          arraycontacto: event.arraycontacto ?? [],
          arraycontactoElimimar: event.arraycontacto ?? [],
        ));

  Future<CreateUpdateEventResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateUpdateEventResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateUpdateEventResponse(response: false, message: '');
    }

    final eventLike = {
      'EVNT_ID_EVENTO_IN': (state.id == 'new') ? '0' : state.id,
      'EVNT_ASUNTO': state.evntAsunto.value,
      'EVNT_FECHA_INICIO_EVENTO':
          "${state.evntFechaInicioEvento?.year.toString().padLeft(4, '0')}-${state.evntFechaInicioEvento?.month.toString().padLeft(2, '0')}-${state.evntFechaInicioEvento?.day.toString().padLeft(2, '0')}",
      'EVNT_FECHA_FIN_EVENTO':
          "${state.evntFechaFinEvento?.year.toString().padLeft(4, '0')}-${state.evntFechaFinEvento?.month.toString().padLeft(2, '0')}-${state.evntFechaFinEvento?.day.toString().padLeft(2, '0')}",
      'EVNT_HORA_INICIO_EVENTO': state.evntHoraInicioEvento,
      'EVNT_HORA_FIN_EVENTO': state.evntHoraFinEvento,
      'EVNT_ID_USUARIO_RESPONSABLE': state.evntIdUsuarioResponsable,
      'EVNT_NOMBRE_USUARIO_RESPONSABLE': state.evntNombreUsuarioResponsable,
      'EVNT_ID_TIPO_GESTION': state.evntIdTipoGestion,
      'EVNT_RUC': state.evntRuc,
      'EVNT_ID_OPORTUNIDAD': state.evntIdOportunidad,
      'EVNT_COMENTARIO': state.evntComentario,
      'EVNT_UBIGEO': state.evntUbigeo,
      'EVNT_COORDENADA_LATITUD': state.evntCoordenadaLatitud,
      'EVNT_COORDENADA_LONGITUD': state.evntCoordenadaLongitud,
      'EVNT_DIRECCION_MAPA': state.evntDireccionMapa,
      'EVNT_ID_RECORDATORIO': state.evntIdRecordatorio,
      'EVNT_NOMBRE_RECORDATORIO': state.evntNombreRecordatorio,
      'EVNT_ID_USUARIO_REGISTRO': state.evntIdUsuarioRegistro,
      'OPT': (state.id == 'new') ? 'INSERT' : 'UPDATE',
      'TODO_DIA': state.todoDia,
      'EVNT_NOMBRE_TIPO_GESTION': state.evntNombreTipoGestion,
      'EVNT_NOMBRE_OPORTUNIDAD': state.evntNombreOportunidad,
      'EVNT_CORREOS_EXTERNOS': state.evntCorreosExternos,
      'ARRAYCONTACTO': state.arraycontacto != null
          ? List<dynamic>.from(state.arraycontacto!.map((x) => x.toJson()))
          : [],
      'ARRAYCONTACTO_ELIMIMAR': state.arraycontactoElimimar != null
          ? List<dynamic>.from(
              state.arraycontactoElimimar!.map((x) => x.toJson()))
          : [],
    };

    try {
      return await onSubmitCallback!(eventLike);
    } catch (e) {
      return CreateUpdateEventResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Name.dirty(state.evntAsunto.value),
      ]),
    );
  }

  void onAsuntoChanged(String value) {
    state = state.copyWith(
        evntAsunto: Name.dirty(value),
        isFormValid: Formz.validate([
          Name.dirty(value),
        ]));
  }

  void onTipoGestionChanged(String id, String name) {
    state = state.copyWith(evntIdTipoGestion: id, evntNombreTipoGestion: name);
  }

  void onEmpresaChanged(String id, String name) {
    state = state.copyWith(evntRuc: id, evntRazon: name);
  }

  void onTodoDiaChanged(String id) {
    state = state.copyWith(todoDia: id);
  }

  void onFechaChanged(DateTime fecha) {
    state =
        state.copyWith(evntFechaInicioEvento: fecha, evntFechaFinEvento: fecha);
  }

  void onHoraInicioChanged(String hora) {
    state = state.copyWith(evntHoraInicioEvento: hora);
  }

  void onHoraFinChanged(String hora) {
    state = state.copyWith(evntHoraFinEvento: hora);
  }

  void onRecordatorioChanged(int id, String name) {
    state =
        state.copyWith(evntIdRecordatorio: id, evntNombreRecordatorio: name);
  }

  void onOportunidadChanged(String id, String name) {
    state = state.copyWith(evntIdOportunidad: id, evntNombreOportunidad: name);
  }

  void onComentariosChanged(String name) {
    state = state.copyWith(evntComentario: name);
  }

  void onCorreosExternosChanged(String correos) {
    state = state.copyWith(evntCorreosExternos: correos);
  }

  void onContactoChanged(Contact contacto) {
    print('DESC: ${contacto.contactoDesc}');

    bool objExist = state.arraycontacto!.any((objeto) =>
        objeto.ecntIdContacto == contacto.id &&
        objeto.nombre == contacto.contactoDesc);

    if (!objExist) {
      ContactArray array = ContactArray();
      array.ecntIdContacto = contacto.id;
      array.nombre = contacto.contactoDesc;

      List<ContactArray> arrayContactos = [...state.arraycontacto ?? [], array];

      print('CONTACTOS');
      print(arrayContactos[0].nombre);

      state = state.copyWith(arraycontacto: arrayContactos);
    } else {
      state = state;
    }
  }

  /*void onContactoChanged(String value, String name) {
    state = state.copyWith(
        actiIdContacto: Contacto.dirty(value),
        actiNombreContacto: name,
        isFormValid: Formz.validate([
          Ruc.dirty(state.actiIdContacto.value),
          TipoGestion.dirty(value),
          Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  void onTipoGestionChanged(String value, String name) {
    state = state.copyWith(
        actiIdTipoGestion: TipoGestion.dirty(value),
        actiNombreTipoGestion: name,
        isFormValid: Formz.validate([
          Ruc.dirty(state.actiRuc.value),
          TipoGestion.dirty(value),
          Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  void onFechaChanged(DateTime fecha) {
    state = state.copyWith(actiFechaActividad: fecha);
  }

  void onHoraChanged(String hora) {
    state = state.copyWith(actiHoraActividad: hora);
  }

  void onOportunidadChanged(String id, String nombre) {
    state = state.copyWith(actiIdOportunidad: id, actiNombreOportunidad: nombre);
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(actiComentario: comentario);
  }

  void onResponsableChanged(String id, String nombre) {
    state = state.copyWith(actiIdUsuarioResponsable: id, actiNombreResponsable: nombre);
  }*/
}

class EventFormState {
  final bool isFormValid;
  final String? id;

  final Name evntAsunto;
  final DateTime? evntFechaInicioEvento;
  final DateTime? evntFechaFinEvento;
  final String? evntHoraInicioEvento;
  final String? evntHoraFinEvento;
  final String? evntHoraRecordatorio;
  final String? evntIdUsuarioResponsable;
  final String? evntNombreUsuarioResponsable;
  final String? evntIdTipoGestion;
  final String? evntRuc;
  final String? evntRazon;
  final String? todoDia;
  final String? evntIdOportunidad;
  final String? evntComentario;
  final String? evntUbigeo;
  final String? evntCoordenadaLatitud;
  final String? evntCoordenadaLongitud;
  final String? evntDireccionMapa;
  final int? evntIdRecordatorio;
  final String? evntNombreRecordatorio;
  final String? evntIdUsuarioRegistro;
  final String? opt;
  final String? evntIdEventoIn;
  final String? evntNombreTipoGestion;
  final String? evntNombreOportunidad;
  final String? evntCorreosExternos;
  final List<ContactArray>? arraycontacto;
  final List<ContactArray>? arraycontactoElimimar;

  EventFormState(
      {this.isFormValid = false,
      this.id,
      this.evntAsunto = const Name.dirty(''),
      this.evntFechaInicioEvento,
      this.evntFechaFinEvento,
      this.evntHoraInicioEvento = '',
      this.evntHoraFinEvento = '',
      this.evntHoraRecordatorio = '',
      this.evntIdUsuarioResponsable = '',
      this.evntNombreUsuarioResponsable = '',
      this.evntIdTipoGestion = '',
      this.evntRuc = '',
      this.evntRazon = '',
      this.evntIdOportunidad = '',
      this.evntComentario = '',
      this.evntUbigeo = '',
      this.evntCoordenadaLatitud = '',
      this.evntCoordenadaLongitud = '',
      this.evntDireccionMapa = '',
      this.evntIdRecordatorio = 1,
      this.evntNombreRecordatorio = '',
      this.evntIdUsuarioRegistro = '',
      this.opt = '',
      this.todoDia = '0',
      this.evntIdEventoIn = '',
      this.evntNombreTipoGestion = '',
      this.evntNombreOportunidad = '',
      this.evntCorreosExternos = '',
      this.arraycontacto,
      this.arraycontactoElimimar});

  EventFormState copyWith({
    bool? isFormValid,
    String? id,
    Name? evntAsunto,
    DateTime? evntFechaInicioEvento,
    DateTime? evntFechaFinEvento,
    String? evntHoraInicioEvento,
    String? evntHoraFinEvento,
    String? evntHoraRecordatorio,
    String? evntIdUsuarioResponsable,
    String? evntNombreUsuarioResponsable,
    String? evntIdTipoGestion,
    String? evntRuc,
    String? evntRazon,
    String? evntIdOportunidad,
    String? evntComentario,
    String? evntUbigeo,
    String? evntCoordenadaLatitud,
    String? evntCoordenadaLongitud,
    String? evntDireccionMapa,
    int? evntIdRecordatorio,
    String? evntNombreRecordatorio,
    String? evntIdUsuarioRegistro,
    String? opt,
    String? todoDia,
    String? evntIdEventoIn,
    String? evntNombreTipoGestion,
    String? evntNombreOportunidad,
    String? evntCorreosExternos,
    List<ContactArray>? arraycontacto,
    List<ContactArray>? arraycontactoElimimar,
  }) =>
      EventFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        evntAsunto: evntAsunto ?? this.evntAsunto,
        evntComentario: evntComentario ?? this.evntComentario,
        evntCoordenadaLatitud:
            evntCoordenadaLatitud ?? this.evntCoordenadaLatitud,
        evntCoordenadaLongitud:
            evntCoordenadaLongitud ?? this.evntCoordenadaLongitud,
        evntCorreosExternos: evntCorreosExternos ?? this.evntCorreosExternos,
        evntDireccionMapa: evntDireccionMapa ?? this.evntDireccionMapa,
        evntFechaFinEvento: evntFechaFinEvento ?? this.evntFechaFinEvento,
        evntFechaInicioEvento:
            evntFechaInicioEvento ?? this.evntFechaInicioEvento,
        evntHoraFinEvento: evntHoraFinEvento ?? this.evntHoraFinEvento,
        evntHoraInicioEvento: evntHoraInicioEvento ?? this.evntHoraInicioEvento,
        evntHoraRecordatorio: evntHoraRecordatorio ?? this.evntHoraRecordatorio,
        evntIdEventoIn: evntIdEventoIn ?? this.evntIdEventoIn,
        evntIdOportunidad: evntIdOportunidad ?? this.evntIdOportunidad,
        evntIdRecordatorio: evntIdRecordatorio ?? this.evntIdRecordatorio,
        evntNombreRecordatorio:
            evntNombreRecordatorio ?? this.evntNombreRecordatorio,
        evntUbigeo: evntUbigeo ?? this.evntUbigeo,
        evntIdTipoGestion: evntIdTipoGestion ?? this.evntIdTipoGestion,
        evntIdUsuarioRegistro:
            evntIdUsuarioRegistro ?? this.evntIdUsuarioRegistro,
        evntIdUsuarioResponsable:
            evntIdUsuarioResponsable ?? this.evntIdUsuarioResponsable,
        evntNombreUsuarioResponsable:
            evntNombreUsuarioResponsable ?? this.evntNombreUsuarioResponsable,
        evntNombreOportunidad:
            evntNombreOportunidad ?? this.evntNombreOportunidad,
        evntNombreTipoGestion:
            evntNombreTipoGestion ?? this.evntNombreTipoGestion,
        evntRuc: evntRuc ?? this.evntRuc,
        evntRazon: evntRazon ?? this.evntRazon,
        todoDia: todoDia ?? this.todoDia,
        opt: opt ?? this.opt,
        arraycontacto: arraycontacto ?? this.arraycontacto,
        arraycontactoElimimar:
            arraycontactoElimimar ?? this.arraycontactoElimimar,
      );
}

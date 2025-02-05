import 'package:crm_app/features/shared/infrastructure/inputs/inputs.dart';

import '../../../../contacts/domain/domain.dart';
import '../../../../users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../domain/domain.dart';
import '../providers.dart';
import '../../../../shared/shared.dart';

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
          evntIdTipoGestion: Select.dirty(event.evntIdTipoGestion),
          evntFechaFinEvento: event.evntFechaFinEvento ?? DateTime.now(),
          evntFechaInicioEvento: event.evntFechaInicioEvento ?? DateTime.now(),
          evntHoraFinEvento: event.evntHoraFinEvento ?? '',
          evntHoraInicioEvento: event.evntHoraInicioEvento ?? '',
          evntHoraRecordatorio: event.evntHoraFinEvento ?? '',
          evntIdEventoIn: event.evntIdEventoIn ?? '',
          evntIdOportunidad: Oportunidad.dirty(event.evntIdOportunidad),
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
          evntRuc: StateCompany.dirty(event.evntRuc ?? ''),
          evntUbigeo: event.evntUbigeo ?? '',
          opt: event.opt ?? '',
          evntLocalCodigo: StateLocal.dirty(event.evntLocalCodigo ?? ''),
          arraycontacto: event.arraycontacto ?? [],
          arraycontactoElimimar: event.arraycontacto ?? [],
          arrayresponsable: event.arrayresponsable ?? [],
          arrayresponsableElimimar: event.arrayresponsableElimimar ?? [],
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
      'EVNT_ID_EVENTO': (state.id == 'new') ? null : state.id,
      'EVNT_ASUNTO': state.evntAsunto.value,
      'EVNT_FECHA_INICIO_EVENTO':
          "${state.evntFechaInicioEvento?.year.toString().padLeft(4, '0')}-${state.evntFechaInicioEvento?.month.toString().padLeft(2, '0')}-${state.evntFechaInicioEvento?.day.toString().padLeft(2, '0')}",
      'EVNT_FECHA_FIN_EVENTO':
          "${state.evntFechaFinEvento?.year.toString().padLeft(4, '0')}-${state.evntFechaFinEvento?.month.toString().padLeft(2, '0')}-${state.evntFechaFinEvento?.day.toString().padLeft(2, '0')}",
      'EVNT_HORA_INICIO_EVENTO': state.evntHoraInicioEvento,
      'EVNT_HORA_FIN_EVENTO': state.evntHoraFinEvento,
      'EVNT_ID_USUARIO_RESPONSABLE': state.evntIdUsuarioResponsable,
      'EVNT_NOMBRE_USUARIO_RESPONSABLE': state.evntNombreUsuarioResponsable,
      'EVNT_ID_TIPO_GESTION': state.evntIdTipoGestion.value,
      'EVNT_RUC': state.evntRuc.value,
      'EVNT_ID_OPORTUNIDAD': state.evntIdOportunidad.value,
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
      'EVNT_LOCAL_CODIGO': state.evntLocalCodigo.value,
      'EVENTOS_INVITACION_CONTACTO': state.arraycontacto != null
          ? List<dynamic>.from(state.arraycontacto!.map((x) => x.toJson()))
          : [],
      'EVENTOS_INVITACION_CONTACTO_ELIMINAR': state.arraycontactoElimimar != null
          ? List<dynamic>.from(
              state.arraycontactoElimimar!.map((x) => x.toJson()))
          : [],
      'EVENTOS_INVITACION_RESPONSABLE': state.arrayresponsable != null
          ? List<dynamic>.from(state.arrayresponsable!.map((x) => x.toJson()))
          : [],
      'EVENTOS_INVITACION_RESPONSABLE_ELIMINAR': state.arrayresponsableElimimar != null
          ? List<dynamic>.from(
              state.arrayresponsableElimimar!.map((x) => x.toJson()))
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
        Select.dirty(state.evntIdTipoGestion.value),
        Oportunidad.dirty(state.evntIdOportunidad.value),
        StateCompany.dirty(state.evntRuc.value),
        StateLocal.dirty(state.evntLocalCodigo.value),
      ]),
    );
  }

  void onAsuntoChanged(String value) {
    state = state.copyWith(
        evntAsunto: Name.dirty(value),
        isFormValid: Formz.validate([
          Name.dirty(value),
          Select.dirty(state.evntIdTipoGestion.value),
          Oportunidad.dirty(state.evntIdOportunidad.value),
          StateCompany.dirty(state.evntRuc.value),
          StateLocal.dirty(state.evntLocalCodigo.value),
        ]));
  }

  void onTipoGestionChanged(String id, String name) {
    state = state.copyWith(
      evntIdTipoGestion: Select.dirty(id),
      evntNombreTipoGestion: name,
      isFormValid: Formz.validate([
        Name.dirty(state.evntAsunto.value),
        Select.dirty(id),
        Oportunidad.dirty(state.evntIdOportunidad.value),
        StateCompany.dirty(state.evntRuc.value),
        StateLocal.dirty(state.evntLocalCodigo.value),
      ]));
  }

  void onEmpresaChanged(String id, String name) {
    //state = state.copyWith(evntRuc: id, evntRazon: name);
    state = state.copyWith(
      evntRuc: StateCompany.dirty(id),
      evntRazon: name,
      evntNombreOportunidad: name,
      evntLocalCodigo: StateLocal.dirty(''),
      arraycontacto: [],
      evntIdOportunidad: Oportunidad.dirty(''),
      isFormValid: Formz.validate([
        Name.dirty(state.evntAsunto.value),
        Select.dirty(state.evntIdTipoGestion.value),
        Oportunidad.dirty(state.evntIdOportunidad.value),
        StateCompany.dirty(id),
        StateLocal.dirty(state.evntLocalCodigo.value),
      ]));
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
    state = state.copyWith(
      evntIdOportunidad: Oportunidad.dirty(id),
      evntNombreOportunidad: name,
      isFormValid: Formz.validate([
        Name.dirty(state.evntAsunto.value),
        Select.dirty(state.evntIdTipoGestion.value),
        Oportunidad.dirty(state.evntIdOportunidad.value),
        StateCompany.dirty(state.evntRuc.value),
        StateLocal.dirty(state.evntLocalCodigo.value),
      ]));
  }

  void onComentariosChanged(String name) {
    state = state.copyWith(evntComentario: name);
  }

  void onCorreosExternosChanged(String correos) {
    state = state.copyWith(evntCorreosExternos: correos);
  }

  void onLocalChanged(String value, String name) {
    state = state.copyWith(
        evntLocalCodigo: StateLocal.dirty(value),
        evntLocalNombre: name,
        isFormValid: Formz.validate([
          Name.dirty(state.evntAsunto.value),
          Select.dirty(state.evntIdTipoGestion.value),
          Oportunidad.dirty(state.evntIdOportunidad.value),
          StateCompany.dirty(state.evntRuc.value),
          StateLocal.dirty(value)
        ]));
  }

  void onContactoChanged(Contact contacto) {

    bool objExist = state.arraycontacto!.any((objeto) =>
        objeto.ecntIdContacto == contacto.id &&
        objeto.nombre == contacto.contactoDesc);

    if (!objExist) {
      ContactArray array = ContactArray();
      array.ecntIdContacto = contacto.id;
      array.nombre = contacto.contactoDesc;
      array.contactoDesc = contacto.contactoDesc;

      List<ContactArray> arrayContactos = [...state.arraycontacto ?? [], array];

      state = state.copyWith(arraycontacto: arrayContactos);
    } else {
      state = state;
    }
  }

  void onDeleteContactoChanged(ContactArray contacto) {
    List<ContactArray> arraycontactoElimimar = [];

    if (state.id != "new") {
      bool objExist = state.arraycontactoElimimar!
          .any((objeto) => objeto.ecntIdContacto == contacto.ecntIdContacto);

      if (!objExist) {
        ContactArray array = ContactArray();
        array.ecntIdContacto = contacto.ecntIdContacto;

        arraycontactoElimimar = [
          ...state.arraycontactoElimimar ?? [],
          array
        ];
      }
    }

    List<ContactArray> arrayUsuarios = [];

    if (state.id == "new") {
      arrayUsuarios = state.arraycontacto!
        .where((user) => user.ecntIdContacto != contacto.ecntIdContacto)
        .toList();
    } else {
      arrayUsuarios = state.arraycontacto!
        .where((user) => user.ecntIdContacto != contacto.ecntIdContacto)
        .toList();
    }

    state = state.copyWith(
        arraycontacto: arrayUsuarios,
        arraycontactoElimimar: arraycontactoElimimar);
  }

  void onResponsableChanged(UserMaster responsable) {

    bool objExist = state.arrayresponsable!.any((objeto) =>
        objeto.ecntIdResponsable == responsable.code);

    if (!objExist) {
      ResponsableArray array = ResponsableArray();
      array.ecntIdResponsable = responsable.code;
      array.nombre = responsable.name;
      array.userreportName = responsable.name;

      List<ResponsableArray> arrayResponsables = [...state.arrayresponsable ?? [], array];

      state = state.copyWith(arrayresponsable: arrayResponsables);
    } else {
      state = state;
    }
  }

  void onDeleteResponsableChanged(ResponsableArray responsable) {
    List<ResponsableArray> arrayresponsableElimimar = [];

    if (state.id != "new") {
      bool objExist = state.arrayresponsableElimimar!
          .any((objeto) => objeto.ecntIdResponsable == responsable.ecntIdResponsable);

      if (!objExist) {
        ResponsableArray array = ResponsableArray();
        array.ecntIdResponsable = responsable.ecntIdResponsable;

        arrayresponsableElimimar = [
          ...state.arrayresponsableElimimar ?? [],
          array
        ];
      }
    }

    List<ResponsableArray> arrayUsuarios = [];

    if (state.id == "new") {
      arrayUsuarios = state.arrayresponsable!
        .where((user) => user.ecntIdResponsable != responsable.ecntIdResponsable)
        .toList();
    } else {
      arrayUsuarios = state.arrayresponsable!
        .where((user) => user.ecntIdResponsable != responsable.ecntIdResponsable)
        .toList();
    }

    state = state.copyWith(
        arrayresponsable: arrayUsuarios,
        arrayresponsableElimimar: arrayresponsableElimimar);
  }
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
  final Select evntIdTipoGestion;
  final StateCompany evntRuc;
  final String? evntRazon;
  final String? todoDia;
  final Oportunidad evntIdOportunidad;
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
  final StateLocal evntLocalCodigo;
  final String? evntLocalNombre;
  final List<ContactArray>? arraycontacto;
  final List<ContactArray>? arraycontactoElimimar;
  final List<ResponsableArray>? arrayresponsable;
  final List<ResponsableArray>? arrayresponsableElimimar;

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
      this.evntIdTipoGestion = const Select.dirty(''),
      this.evntRuc = const StateCompany.dirty(''),
      this.evntRazon = '',
      this.evntIdOportunidad = const Oportunidad.dirty(''),
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
      this.evntLocalCodigo = const StateLocal.dirty(''),
      this.evntLocalNombre = '',
      this.arraycontacto,
      this.arraycontactoElimimar,
      this.arrayresponsable,
      this.arrayresponsableElimimar
      });

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
    Select? evntIdTipoGestion,
    StateCompany? evntRuc,
    String? evntRazon,
    Oportunidad? evntIdOportunidad,
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
    StateLocal? evntLocalCodigo,
    String? evntLocalNombre,
    List<ContactArray>? arraycontacto,
    List<ContactArray>? arraycontactoElimimar,
    List<ResponsableArray>? arrayresponsable,
    List<ResponsableArray>? arrayresponsableElimimar,
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
        evntLocalCodigo: evntLocalCodigo ?? this.evntLocalCodigo,
        evntLocalNombre: evntLocalNombre ?? this.evntLocalNombre,
        arraycontacto: arraycontacto ?? this.arraycontacto,
        arraycontactoElimimar:
            arraycontactoElimimar ?? this.arraycontactoElimimar,
        arrayresponsable: arrayresponsable ?? this.arrayresponsable,
        arrayresponsableElimimar:
            arrayresponsableElimimar ?? this.arrayresponsableElimimar,
      );
}

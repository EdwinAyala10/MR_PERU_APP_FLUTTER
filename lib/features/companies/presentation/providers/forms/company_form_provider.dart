import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final companyFormProvider = StateNotifierProvider.autoDispose
    .family<CompanyFormNotifier, CompanyFormState, Company>((ref, company) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(companiesProvider.notifier).createOrUpdateCompany;

  return CompanyFormNotifier(
    company: company,
    onSubmitCallback: createUpdateCallback,
  );
});

class CompanyFormNotifier extends StateNotifier<CompanyFormState> {
  final Future<CreateUpdateCompanyResponse> Function(
      Map<dynamic, dynamic> companyLike)? onSubmitCallback;

  CompanyFormNotifier({
    this.onSubmitCallback,
    required Company company,
  }) : super(CompanyFormState(
          rucId: company.rucId,
          ruc: Ruc.dirty(company.ruc),
          razon: Razon.dirty(company.razon),
          direccion: company.direccion ?? '',
          telefono: Phone.dirty(company.telefono ?? ''),
          observaciones: company.observaciones ?? '',
          departamento: company.departamento ?? '',
          provincia: company.provincia ?? '',
          distrito: company.distrito ?? '',
          seguimientoComentario: company.seguimientoComentario ?? '',
          website: company.website ?? '',
          calificacion: company.calificacion ?? '',
          usuarioRegistro: company.usuarioRegistro ?? '',
          visibleTodos: company.visibleTodos ?? '',
          email: company.email ?? '',
          codigoPostal: company.codigoPostal ?? '',
          tipoCliente: company.tipocliente ?? '',
          estado: company.estado ?? '',
          localNombre: '',
          localDireccion: Address.dirty(company.localDireccion ?? ''),
          localDepartamento: '',
          localProvincia: '',
          localDistrito: '',
          voltajeTension: '0',
          enviarNotificacion: 'SI',
          orden: '',
          localTipo: '',
          localCodigoPostal: '',
          coordenadasGeo: '',
          coordenadasLongitud: '',
          cchkIdEstadoCheck: '',
          coordenadasLatitud: '',
          ubigeoCodigo: '',
          clienteNombreEstado: '',
          localDepartamentoDesc: '',
          localProvinciaDesc: '',
          localDistritoDesc: '',
          userreporteName: '',
          clienteNombreTipo: '',
          arrayresponsables: company.arrayresponsables ?? [],
          arrayresponsablesEliminar: company.arrayresponsablesEliminar ?? [],
        ));

  Future<CreateUpdateCompanyResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid)
      return CreateUpdateCompanyResponse(
          response: false, message: 'Campos requeridos.');

    if (onSubmitCallback == null)
      return CreateUpdateCompanyResponse(response: false, message: '');

    final companyLike = {
      'RUCID': (state.rucId == 'new') ? null : state.rucId,
      'RUC': state.ruc.value,
      'RAZON': state.razon.value,
      'DIRECCION': state.direccion,
      'TELEFONO': state.telefono.value,
      'OBSERVACIONES': state.observaciones,
      'DEPARTAMENTO': state.departamento,
      'PROVINCIA': state.provincia,
      'DISTRITO': state.distrito,
      'CLIENTE_COORDENADAS_GEO': state.clienteCoordenadasGeo,
      'CLIENTE_COORDENADAS_LONGITUD': state.clienteCoordenadasLongitud,
      'CLIENTE_COORDENADAS_LATITUD': state.clienteCoordenadasLatitud,
      'SEGUIMIENTO_COMENTARIO': state.seguimientoComentario,
      'WEBSITE': state.website,
      'CALIFICACION': state.calificacion,
      'USUARIO_REGISTRO': state.usuarioRegistro,
      'VISIBLE_TODOS': state.visibleTodos,
      'EMAIL': state.email,
      'CODIGO_POSTAL': state.codigoPostal,
      'TIPOCLIENTE': state.tipoCliente,
      'ESTADO': state.estado,
      'LOCAL_NOMBRE': state.localNombre,
      'LOCAL_DIRECCION': state.localDireccion.value,
      'LOCAL_DEPARTAMENTO': state.localDepartamento,
      'LOCAL_PROVINCIA': state.localProvincia,
      'LOCAL_DISTRITO': state.localDistrito,
      'VOLTAJE_TENSION': state.voltajeTension,
      'ENVIAR_NOTIFICACION': state.enviarNotificacion,
      'ORDEN': state.orden,
      'LOCAL_TIPO': state.localTipo,
      'COORDENADAS_GEO': state.coordenadasGeo,
      'COORDENADAS_LONGITUD': state.coordenadasLongitud,
      'COORDENADAS_LATITUD': state.coordenadasLatitud,
      'CLIENTE_NOMBRE_TIPO': state.clienteNombreTipo,
      'UBIGEO_CODIGO': state.ubigeoCodigo,
      'LOCAL_CODIGO_POSTAL': state.localCodigoPostal,
      'LOCAL_DEPARTAMENTO_DESC': state.localDepartamentoDesc,
      'LOCAL_PROVINCIA_DESC': state.localProvinciaDesc,
      'CCHK_ID_ESTADO_CHECK': state.cchkIdEstadoCheck,
      'CLIENTE_NOMBRE_ESTADO': state.clienteNombreEstado,
      'LOCAL_DISTRITO_DESC': state.localDistritoDesc,
      'CLIENTES_RESPONSABLE': state.arrayresponsables != null
          ? List<dynamic>.from(state.arrayresponsables!.map((x) => x.toJson()))
          : [],
      'CLIENTES_RESPONSABLE_ELIMINAR': state.arrayresponsablesEliminar != null
          ? List<dynamic>.from(
              state.arrayresponsablesEliminar!.map((x) => x.toJson()))
          : [],
    };

    try {
      return await onSubmitCallback!(companyLike);
    } catch (e) {
      return CreateUpdateCompanyResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Ruc.dirty(state.ruc.value),
        Razon.dirty(state.razon.value),
        Phone.dirty(state.telefono.value),
        //Address.dirty(state.direccion.value),
        Address.dirty(state.localDireccion.value),
      ]),
    );
  }

  void onRucChanged(String value) {
    state = state.copyWith(
        ruc: Ruc.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(value),
          Razon.dirty(state.razon.value),
          Phone.dirty(state.telefono.value),
          //Address.dirty(state.direccion.value),
          Address.dirty(state.localDireccion.value),
        ]));
  }

  void onRazonChanged(String value) {
    state = state.copyWith(
        razon: Razon.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(value),
          Phone.dirty(state.telefono.value),
          //Address.dirty(state.direccion.value),
          Address.dirty(state.localDireccion.value),
        ]));
  }

  void onTipoChanged(String tipoId, String name) {
    state = state.copyWith(tipoCliente: tipoId, clienteNombreTipo: name);
  }

  void onDepartamentoChanged(String id) {
    state = state.copyWith(localDepartamento: id);
  }

  void onNombreLocalChanged(String name) {
    state = state.copyWith(localNombre: name);
  }

  void onDistritoChanged(String id) {
    state = state.copyWith(localDistrito: id);
  }

  void onProvinciaChanged(String id) {
    state = state.copyWith(localProvincia: id);
  }

  void onTipoLocalChanged(String id) {
    state = state.copyWith(localTipo: id);
  }

  void onEstadoChanged(String estadoId, String name) {
    state = state.copyWith(estado: estadoId, clienteNombreEstado: name);
  }

  void onCalificacionChanged(String calificacionId) {
    state = state.copyWith(calificacion: calificacionId);
  }

  void onVisibleTodosChanged(String visible) {
    state = state.copyWith(visibleTodos: visible);
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(seguimientoComentario: comentario);
  }

  void onRecomendacionChanged(String observacion) {
    state = state.copyWith(observaciones: observacion);
  }

  void onEmailChanged(String email) {
    state = state.copyWith(email: email);
  }

  void onWebChanged(String web) {
    state = state.copyWith(website: web);
  }

  void onTelefonoChanged(String value) {
    state = state.copyWith(
        telefono: Phone.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(state.razon.value),
          Phone.dirty(value),
          //Address.dirty(state.direccion.value),
          Address.dirty(state.localDireccion.value),
        ]));
  }

  /*void onDireccionChanged(String value) {
    state = state.copyWith(
        direccion: Address.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(state.razon.value),
          Phone.dirty(state.telefono.value),
          Address.dirty(value),
          Address.dirty(state.localDireccion.value),
        ]));
  }*/

  void onLoadAddressCompanyChanged(String direccion, String coors, String lat,
      String lng, String ubigeo, String dep, String prov, String dist) {
    state = state.copyWith(
        //direccion: Address.dirty(direccion),
        clienteCoordenadasGeo: coors,
        clienteCoordenadasLatitud: lat,
        clienteCoordenadasLongitud: lng,
        ubigeoCodigo: ubigeo,
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(state.razon.value),
          Phone.dirty(state.telefono.value),
          //Address.dirty(direccion),
          Address.dirty(state.localDireccion.value),
        ]));
  }

  void onLoadAddressCompanyLocalChanged(
      String direccion,
      String coors,
      String lat,
      String lng,
      String ubigeo,
      String dep,
      String prov,
      String dist) {
    state = state.copyWith(
        localDireccion: Address.dirty(direccion),
        coordenadasGeo: coors,
        coordenadasLatitud: lat,
        coordenadasLongitud: lng,
        localCodigoPostal: ubigeo,
        localDepartamentoDesc: dep,
        localDistritoDesc: dist,
        localProvinciaDesc: prov,
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(state.razon.value),
          Phone.dirty(state.telefono.value),
          //Address.dirty(state.direccion.value),
          Address.dirty(direccion),
        ]));
  }

  void onLocalDireccionChanged(String value) {
    state = state.copyWith(
        localDireccion: Address.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(state.razon.value),
          Phone.dirty(state.telefono.value),
          //Address.dirty(state.direccion.value),
          Address.dirty(value)
        ]));
  }

  void onCodigoPostaChanged(String codigoPostal) {
    state = state.copyWith(codigoPostal: codigoPostal);
  }

  void onUsuarioChanged(UserMaster usuario) {
    bool objExist = state.arrayresponsables!.any(
        (objeto) => objeto.id == usuario.id && objeto.name == usuario.name);

    if (!objExist) {
      ArrayUser array = ArrayUser();
      array.idResponsable = usuario.id;
      array.cresIdUsuarioResponsable = usuario.code;
      array.userreportName = usuario.name;
      array.nombreResponsable = usuario.name;

      List<ArrayUser> arrayUsuarios = [...state.arrayresponsables ?? [], array];

      state = state.copyWith(arrayresponsables: arrayUsuarios);
    } else {
      state = state;
    }
  }

  void onDeleteUserChanged(ArrayUser item) {
    List<ArrayUser> arrayUsuariosEliminar = [];

    if (state.rucId != "new") {
      bool objExist = state.arrayresponsablesEliminar!
          .any((objeto) => objeto.cresIdClienteResp == item.cresIdClienteResp);

      if (!objExist) {
        ArrayUser array = ArrayUser();
        array.cresIdClienteResp = item.cresIdClienteResp;

        arrayUsuariosEliminar = [
          ...state.arrayresponsablesEliminar ?? [],
          array
        ];
      }
    }

    List<ArrayUser> arrayUsuarios = state.arrayresponsables!
        .where((user) => user.cresIdClienteResp != item.cresIdClienteResp)
        .toList();
    state = state.copyWith(
        arrayresponsables: arrayUsuarios,
        arrayresponsablesEliminar: arrayUsuariosEliminar);
  }
}

class CompanyFormState {
  final bool isFormValid;
  final String? rucId;
  final Ruc ruc;
  final Razon razon;
  final String direccion;
  final Phone telefono;
  final String observaciones;
  final String departamento;
  final String provincia;
  final String distrito;
  final String clienteCoordenadasGeo;
  final String clienteCoordenadasLatitud;
  final String clienteCoordenadasLongitud;
  final String seguimientoComentario;
  final String website;
  final String calificacion;
  final String usuarioRegistro;
  final String visibleTodos;
  final String email;
  final String codigoPostal;
  final String tipoCliente;
  final String estado;
  final String localNombre;
  final Address localDireccion;
  final String localDepartamento;
  final String localProvincia;
  final String localDistrito;
  final String voltajeTension;
  final String enviarNotificacion;
  final String orden;
  final String localTipo;
  final String coordenadasGeo;
  final String coordenadasLongitud;
  final String coordenadasLatitud;
  final String ubigeoCodigo;
  final String localDepartamentoDesc;
  final String localProvinciaDesc;
  final String localDistritoDesc;
  final String? localCodigoPostal;
  final String cchkIdEstadoCheck;
  final String? clienteNombreTipo;
  final String? clienteNombreEstado;
  final List<ArrayUser>? arrayresponsables;
  final List<ArrayUser>? arrayresponsablesEliminar;
  final List<Contact>? contacts;
  final List<Opportunity>? opportunities;
  final List<Activity>? activities;
  final List<Event>? events;
  final String? userreporteName;

  CompanyFormState(
      {this.isFormValid = false,
      this.rucId,
      this.ruc = const Ruc.dirty(''),
      this.razon = const Razon.dirty(''),
      this.direccion = '',
      this.telefono = const Phone.dirty(''),
      this.observaciones = '',
      this.departamento = '',
      this.provincia = '',
      this.distrito = '',
      this.clienteNombreTipo = '',
      this.clienteNombreEstado = '',
      this.clienteCoordenadasGeo = '',
      this.clienteCoordenadasLatitud = '',
      this.clienteCoordenadasLongitud = '',
      this.seguimientoComentario = '',
      this.website = '',
      this.calificacion = '',
      this.usuarioRegistro = '',
      this.visibleTodos = '',
      this.email = '',
      this.codigoPostal = '',
      this.tipoCliente = '',
      this.estado = '',
      this.localNombre = '',
      this.localCodigoPostal = '',
      this.localDireccion = const Address.dirty(''),
      this.localProvincia = '',
      this.localDepartamento = '',
      this.localDistrito = '',
      this.voltajeTension = '',
      this.enviarNotificacion = '',
      this.orden = '',
      this.localTipo = '',
      this.coordenadasGeo = '',
      this.coordenadasLongitud = '',
      this.coordenadasLatitud = '',
      this.ubigeoCodigo = '',
      this.localDepartamentoDesc = '',
      this.localProvinciaDesc = '',
      this.cchkIdEstadoCheck = '',
      this.arrayresponsables,
      this.arrayresponsablesEliminar,
      this.contacts,
      this.opportunities,
      this.activities,
      this.events,
      this.userreporteName = '',
      this.localDistritoDesc = ''});

  CompanyFormState copyWith({
    bool? isFormValid,
    Ruc? ruc,
    String? rucId,
    Razon? razon,
    String? direccion,
    Phone? telefono,
    String? observaciones,
    String? departamento,
    String? provincia,
    String? clienteNombreTipo,
    String? distrito,
    String? clienteNombreEstado,
    String? clienteCoordenadasGeo,
    String? clienteCoordenadasLatitud,
    String? clienteCoordenadasLongitud,
    String? seguimientoComentario,
    String? website,
    String? calificacion,
    String? usuarioRegistro,
    String? visibleTodos,
    String? email,
    String? codigoPostal,
    String? tipoCliente,
    String? estado,
    String? localNombre,
    Address? localDireccion,
    String? localDepartamento,
    String? localProvincia,
    String? localDistrito,
    String? voltajeTension,
    String? enviarNotificacion,
    String? orden,
    String? localTipo,
    String? coordenadasGeo,
    String? coordenadasLongitud,
    String? coordenadasLatitud,
    String? ubigeoCodigo,
    String? localDepartamentoDesc,
    String? localProvinciaDesc,
    String? cchkIdEstadoCheck,
    String? userreporteName,
    String? localDistritoDesc,
    String? localCodigoPostal,
    List<ArrayUser>? arrayresponsables,
    List<ArrayUser>? arrayresponsablesEliminar,
    List<Contact>? contacts,
    List<Opportunity>? opportunities,
    List<Activity>? activities,
    List<Event>? events,
  }) =>
      CompanyFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        ruc: ruc ?? this.ruc,
        rucId: rucId ?? this.rucId,
        razon: razon ?? this.razon,
        direccion: direccion ?? this.direccion,
        telefono: telefono ?? this.telefono,
        observaciones: observaciones ?? this.observaciones,
        departamento: departamento ?? this.departamento,
        clienteNombreTipo: clienteNombreTipo ?? this.clienteNombreTipo,
        provincia: provincia ?? this.provincia,
        clienteNombreEstado: clienteNombreEstado ?? this.clienteNombreEstado,
        distrito: distrito ?? this.distrito,
        clienteCoordenadasGeo:
            clienteCoordenadasGeo ?? this.clienteCoordenadasGeo,
        clienteCoordenadasLatitud:
            clienteCoordenadasLatitud ?? this.clienteCoordenadasLatitud,
        clienteCoordenadasLongitud:
            clienteCoordenadasLongitud ?? this.clienteCoordenadasLongitud,
        seguimientoComentario:
            seguimientoComentario ?? this.seguimientoComentario,
        website: website ?? this.website,
        calificacion: calificacion ?? this.calificacion,
        usuarioRegistro: usuarioRegistro ?? this.usuarioRegistro,
        visibleTodos: visibleTodos ?? this.visibleTodos,
        email: email ?? this.email,
        codigoPostal: codigoPostal ?? this.codigoPostal,
        tipoCliente: tipoCliente ?? this.tipoCliente,
        estado: estado ?? this.estado,
        localNombre: localNombre ?? this.localNombre,
        localDireccion: localDireccion ?? this.localDireccion,
        localDepartamento: localDepartamento ?? this.localDepartamento,
        localDistrito: localDistrito ?? this.localDistrito,
        voltajeTension: voltajeTension ?? this.voltajeTension,
        enviarNotificacion: enviarNotificacion ?? this.enviarNotificacion,
        orden: orden ?? this.orden,
        localCodigoPostal: localCodigoPostal ?? this.localCodigoPostal,
        localTipo: localTipo ?? this.localTipo,
        coordenadasGeo: coordenadasGeo ?? this.coordenadasGeo,
        coordenadasLongitud: coordenadasLongitud ?? this.coordenadasLongitud,
        coordenadasLatitud: coordenadasLatitud ?? this.coordenadasLatitud,
        ubigeoCodigo: ubigeoCodigo ?? this.ubigeoCodigo,
        localDepartamentoDesc:
            localDepartamentoDesc ?? this.localDepartamentoDesc,
        localProvinciaDesc: localProvinciaDesc ?? this.localProvinciaDesc,
        localDistritoDesc: localDistritoDesc ?? this.localDistritoDesc,
        arrayresponsables: arrayresponsables ?? this.arrayresponsables,
        arrayresponsablesEliminar:
            arrayresponsablesEliminar ?? this.arrayresponsablesEliminar,
        cchkIdEstadoCheck: cchkIdEstadoCheck ?? this.cchkIdEstadoCheck,
        contacts: contacts ?? this.contacts,
        userreporteName: userreporteName ?? this.userreporteName,
        opportunities: opportunities ?? this.opportunities,
        activities: activities ?? this.activities,
        events: events ?? this.events,
      );
}

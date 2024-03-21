import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
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
          direccion: Address.dirty(company.direccion ?? ''),
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
          localDireccion: '',
          localDepartamento: '',
          localProvincia: '',
          localDistrito: '',
          voltajeTension: '0',
          enviarNotificacion: 'SI',
          orden: '',
          localTipo: '',
          coordenadasGeo: '',
          coordenadasLongitud: '',
          cchkIdEstadoCheck: '',
          coordenadasLatitud: '',
          ubigeoCodigo: '',
          localDepartamentoDesc: '',
          localProvinciaDesc: '',
          localDistritoDesc: '',
          arrayresponsables: company.arrayresponsables ?? [],
        ));

  Future<CreateUpdateCompanyResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid)
      return CreateUpdateCompanyResponse(
          response: false, message: 'Campos requeridos.');

    if (onSubmitCallback == null)
      return CreateUpdateCompanyResponse(response: false, message: '');

    final companyLike = {
      'A': state.rucId,
      'RUCID': (state.rucId == 'new') ? null : state.rucId,
      'RUC': state.ruc.value,
      'RAZON': state.razon.value,
      'DIRECCION': state.direccion.value,
      'TELEFONO': state.telefono.value,
      'OBSERVACIONES': state.observaciones,
      'DEPARTAMENTO': state.departamento,
      'PROVINCIA': state.provincia,
      'DISTRITO': state.distrito,
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
      'LOCAL_DIRECCION': state.localDireccion,
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
      'UBIGEO_CODIGO': state.ubigeoCodigo,
      'LOCAL_DEPARTAMENTO_DESC': state.localDepartamentoDesc,
      'LOCAL_PROVINCIA_DESC': state.localProvinciaDesc,
      'CCHK_ID_ESTADO_CHECK': state.cchkIdEstadoCheck,
      'LOCAL_DISTRITO_DESC': state.localDistritoDesc,
      'ARRAYRESPONSABLES': state.arrayresponsables != null
          ? List<dynamic>.from(state.arrayresponsables!.map((x) => x.toJson()))
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
        Address.dirty(state.direccion.value),
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
          Address.dirty(state.direccion.value),
        ]));
  }

  void onRazonChanged(String value) {
    state = state.copyWith(
        razon: Razon.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(value),
          Phone.dirty(state.telefono.value),
          Address.dirty(state.direccion.value),
        ]));
  }

  void onTipoChanged(String tipoId) {
    state = state.copyWith(tipoCliente: tipoId);
  }

  void onEstadoChanged(String estadoId) {
    state = state.copyWith(estado: estadoId);
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
        ]));
  }

  void onDireccionChanged(String value) {
    state = state.copyWith(
        direccion: Address.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Razon.dirty(state.razon.value),
          Phone.dirty(state.telefono.value),
          Address.dirty(value),
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
      array.id = usuario.id;
      array.idResponsable = usuario.id;
      array.name = usuario.name;

      List<ArrayUser> arrayUsuarios = [...state.arrayresponsables ?? [], array];

      state = state.copyWith(arrayresponsables: arrayUsuarios);
    } else {
      state = state;
    }
  }

  void onDeleteUserChanged(ArrayUser item) {
    List<ArrayUser> arrayUsuarios =
        state.arrayresponsables!.where((user) => user.id != item.id).toList();
    state = state.copyWith(arrayresponsables: arrayUsuarios);
  }
}

class CompanyFormState {
  final bool isFormValid;
  final String? rucId;
  final Ruc ruc;
  final Razon razon;
  final Address direccion;
  final Phone telefono;
  final String observaciones;
  final String departamento;
  final String provincia;
  final String distrito;
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
  final String localDireccion;
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
  final String cchkIdEstadoCheck;
  final List<ArrayUser>? arrayresponsables;

  CompanyFormState(
      {this.isFormValid = false,
      this.rucId,
      this.ruc = const Ruc.dirty(''),
      this.razon = const Razon.dirty(''),
      this.direccion = const Address.dirty(''),
      this.telefono = const Phone.dirty(''),
      this.observaciones = '',
      this.departamento = '',
      this.provincia = '',
      this.distrito = '',
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
      this.localDireccion = '',
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
      this.localDistritoDesc = ''});

  CompanyFormState copyWith({
    bool? isFormValid,
    Ruc? ruc,
    String? rucId,
    Razon? razon,
    Address? direccion,
    Phone? telefono,
    String? observaciones,
    String? departamento,
    String? provincia,
    String? distrito,
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
    String? localDireccion,
    String? localDepartamento,
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
    String? localDistritoDesc,
    List<ArrayUser>? arrayresponsables,
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
        provincia: provincia ?? this.provincia,
        distrito: distrito ?? this.distrito,
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
        cchkIdEstadoCheck: cchkIdEstadoCheck ?? this.cchkIdEstadoCheck,
      );
}

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
  final Future<bool> Function(Map<String, dynamic> companyLike)?
      onSubmitCallback;

  CompanyFormNotifier({
    this.onSubmitCallback,
    required Company company,
  }) : super(CompanyFormState(
          ruc: Ruc.dirty(company.ruc),
          razon: Razon.dirty(company.razon),
          direccion: company.direccion,
          telefono: company.telefono,
          observaciones: company.observaciones,
          departamento: company.departamento,
          provincia: company.provincia,
          distrito: company.distrito,
          seguimientoComentario: company.seguimientoComentario,
          website: company.website,
          calificacion: company.calificacion,
          usuarioRegistro: company.usuarioRegistro,
          visibleTodos: company.visibleTodos,
          email: company.email,
          codigoPostal: company.codigoPostal,
          tipoCliente: company.tipocliente,
          estado: company.estado,
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
          coordenadasLatitud: '',
          ubigeoCodigo: '',
          localDepartamentoDesc: '',
          localProvinciaDesc: '',
          localDistritoDesc: '',
        ));

  Future<bool> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) return false;

    if (onSubmitCallback == null) return false;

    final companyLike = {
      'ruc': (state.ruc == 'new') ? null : state.ruc,
      'razon': state.razon,
      'direccion': state.direccion,
      'telefono': state.telefono,
      'observaciones': state.observaciones,
      'departamento': state.departamento,
      'provincia': state.provincia,
      'distrito': state.distrito,
      'seguimientoComentario': state.seguimientoComentario,
      'website': state.website,
      'calificacion': state.calificacion,
      'usuarioRegistro': state.usuarioRegistro,
      'visibleTodos': state.visibleTodos,
      'email': state.email,
      'codigoPostal': state.codigoPostal,
      'tipoCliente': state.tipoCliente,
      'estado': state.estado,
      'localNombre': state.localNombre,
      'localDireccion': state.localDireccion,
      'localDepartamento': state.localDepartamento,
      'localProvincia': state.localProvincia,
      'localDistrito': state.localDistrito,
      'voltajeTension': state.voltajeTension,
      'enviarNotificacion': state.enviarNotificacion,
      'orden': state.orden,
      'localTipo': state.localTipo,
      'coordenadasGeo': state.coordenadasGeo,
      'coordenadasLongitud': state.coordenadasLongitud,
      'coordenadasLatitud': state.coordenadasLatitud,
      'ubigeoCodigo': state.ubigeoCodigo,
      'localDepartamentoDesc': state.localDepartamentoDesc,
      'localProvinciaDesc': state.localProvinciaDesc,
      'localDistritoDesc': state.localDistritoDesc,
    };

    try {
      return await onSubmitCallback!(companyLike);
    } catch (e) {
      return false;
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Ruc.dirty(state.ruc.value),
      ]),
    );
  }

  void onRucChanged(String value) {
    state = state.copyWith(
      ruc: Ruc.dirty(value),
      isFormValid: Formz.validate([
        Ruc.dirty(value),
        Razon.dirty(state.razon.value),
      ]));
  }

  void onRazonChanged(String value) {
    state = state.copyWith(
      razon: Razon.dirty(value),
      isFormValid: Formz.validate([
        Ruc.dirty(state.ruc.value),
        Razon.dirty(value)
      ]));
  }

  void onTipoChanged(String tipoId) {
    state = state.copyWith(tipoCliente:tipoId);
  }

  void onEstadoChanged(String estadoId) {
    state = state.copyWith(estado:estadoId);
  }

  void onCalificacionChanged(String calificacionId) {
    state = state.copyWith(calificacion:calificacionId);
  }

  void onVisibleTodosChanged(String visible) {
    state = state.copyWith(visibleTodos:visible);
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(seguimientoComentario:comentario);
  }

  void onRecomendacionChanged(String observacion) {
    state = state.copyWith(observaciones:observacion);
  }

  void onEmailChanged(String email) {
    state = state.copyWith(email:email);
  }

  void onWebChanged(String web) {
    state = state.copyWith(website:web);
  }

  void onDireccionChanged(String direccion) {
    state = state.copyWith(direccion:direccion);
  }

  void onCodigoPostaChanged(String codigoPostal) {
    state = state.copyWith(codigoPostal:codigoPostal);
  }

}

class CompanyFormState {
  final bool isFormValid;
  final Ruc ruc;
  final Razon razon;
  final String direccion;
  final String telefono;
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

  CompanyFormState(
      {this.isFormValid = false,
      this.ruc = const Ruc.dirty(''),
      this.razon = const Razon.dirty(''),
      this.direccion = '',
      this.telefono = '',
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
      this.localDistritoDesc = ''
  });

  CompanyFormState copyWith({
    bool? isFormValid,
    Ruc? ruc,
    Razon? razon,
    String? direccion,
    String? telefono,
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
    String? localDistritoDesc,
  }) =>
      CompanyFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        ruc: ruc ?? this.ruc,
        razon: razon ?? this.razon,
        direccion: direccion ?? this.direccion,
        telefono: telefono ?? this.telefono,
        observaciones: observaciones ?? this.observaciones,
        departamento: departamento ?? this.departamento,
        provincia: provincia ?? this.provincia,
        distrito: distrito ?? this.distrito,
        seguimientoComentario: seguimientoComentario ?? this.seguimientoComentario,
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
        localDepartamentoDesc: localDepartamentoDesc ?? this.localDepartamentoDesc,
        localProvinciaDesc: localProvinciaDesc ?? this.localProvinciaDesc,
        localDistritoDesc: localDistritoDesc ?? this.localDistritoDesc,
      );
}

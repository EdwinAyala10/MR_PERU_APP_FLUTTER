
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final companyCheckInFormProvider = StateNotifierProvider.autoDispose
    .family<CompanyCheckInFormNotifier, CompanyCheckInFormState, CompanyCheckIn>((ref, companyCheckIn) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(companiesProvider.notifier).createOrUpdateCompanyCheckIn;

  return CompanyCheckInFormNotifier(
    companyCheckIn: companyCheckIn,
    onSubmitCallback: createUpdateCallback,
  );
});

class CompanyCheckInFormNotifier extends StateNotifier<CompanyCheckInFormState> {
  final Future<CreateUpdateCompanyCheckInResponse> Function(
      Map<dynamic, dynamic> companyCheckInLike)? onSubmitCallback;

  CompanyCheckInFormNotifier({
    this.onSubmitCallback,
    required CompanyCheckIn companyCheckIn,
  }) : super(CompanyCheckInFormState(
          cchkIdClientesCheck: companyCheckIn.cchkIdClientesCheck,
          cchkRuc: Ruc.dirty(companyCheckIn.cchkRuc),
          cchkRazon: companyCheckIn.cchkRazon ?? '',
          cchkIdOportunidad: Select.dirty(companyCheckIn.cchkIdOportunidad),
          cchkIdContacto: Select.dirty(companyCheckIn.cchkIdContacto),
          cchkCoordenadaLatitud: companyCheckIn.cchkCoordenadaLatitud,
          cchkCoordenadaLongitud: companyCheckIn.cchkCoordenadaLongitud,
          cchkDireccionMapa: companyCheckIn.cchkDireccionMapa ?? '',
          cchkIdComentario: companyCheckIn.cchkIdComentario ?? '',
          cchkIdEstadoCheck: companyCheckIn.cchkIdEstadoCheck ?? '01',
          cchkIdUsuarioRegistro: companyCheckIn.cchkIdUsuarioRegistro ?? '',
          cchkIdUsuarioResponsable: companyCheckIn.cchkIdUsuarioResponsable ?? '',
          cchkNombreUsuarioResponsable: companyCheckIn.cchkNombreUsuarioResponsable ?? '',
          cchkNombreContacto: companyCheckIn.cchkNombreContacto ?? '',
          cchkNombreOportunidad: companyCheckIn.cchkNombreOportunidad ?? '',
          cchkUbigeo: companyCheckIn.cchkUbigeo ?? '',
        ));

  Future<CreateUpdateCompanyCheckInResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid)
      return CreateUpdateCompanyCheckInResponse(
          response: false, message: 'Campos requeridos.');

    if (onSubmitCallback == null)
      return CreateUpdateCompanyCheckInResponse(response: false, message: '');

    final companyCheckInLike = {
      'CCHK_ID_CLIENTES_CHECK': (state.cchkIdClientesCheck == 'new') ? null : state.cchkIdClientesCheck,
      'CCHK_RUC': state.cchkRuc.value,
      'CCHK_COORDENADA_LATITUD': state.cchkCoordenadaLatitud,
      'CCHK_COORDENADA_LONGITUD': state.cchkCoordenadaLongitud,
      'CCHK_ID_OPORTUNIDAD': state.cchkIdOportunidad.value,
      'CCHK_ID_CONTACTO': state.cchkIdContacto.value,
      'CCHK_ID_ESTADO_CHECK': state.cchkIdEstadoCheck,
      'CCHK_ID_COMENTARIO': state.cchkIdComentario,
      'CCHK_ID_USUARIO_RESPONSABLE': state.cchkIdUsuarioResponsable,
      'CCHK_NOMBRE_USUARIO_RESPONSABLE': state.cchkNombreUsuarioResponsable,
      'CCHK_UBIGEO': state.cchkUbigeo,
      'CCHK_DIRECCION_MAPA': state.cchkDireccionMapa,
      'CCHK_ID_USUARIO_REGISTRO': state.cchkIdUsuarioRegistro,
    };

    try {
      return await onSubmitCallback!(companyCheckInLike);
    } catch (e) {
      return CreateUpdateCompanyCheckInResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Ruc.dirty(state.cchkRuc.value),
        Select.dirty(state.cchkIdContacto.value),
        Select.dirty(state.cchkIdOportunidad.value),
      ]),
    );
  }

  void onEmpresaChanged(String value) {
    state = state.copyWith(
        cchkRuc: Ruc.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(value),
          Select.dirty(state.cchkIdContacto.value),
          Select.dirty(state.cchkIdOportunidad.value),
        ]));
  }

  void onOportunidadChanged(String value, String name) {
    state = state.copyWith(
        cchkIdOportunidad: Select.dirty(value),
        cchkNombreOportunidad: name,
        isFormValid: Formz.validate([
          Ruc.dirty(state.cchkRuc.value),
          Select.dirty(state.cchkIdContacto.value),
          Select.dirty(value),
        ]));
  }

  void onContactoChanged(String value, String  name) {
    state = state.copyWith(
        cchkIdContacto: Select.dirty(value),
        cchkNombreContacto: name,
        isFormValid: Formz.validate([
          Ruc.dirty(state.cchkRuc.value),
          Select.dirty(value),
          Select.dirty(state.cchkIdOportunidad.value),
        ]));
  }

  void onDireccionChanged(String value) {
    state = state.copyWith(cchkDireccionMapa: value);
  }

  void onComentarioChanged(String value) {
    state = state.copyWith(cchkIdComentario: value);
  }

}

class CompanyCheckInFormState {
  final bool isFormValid;
  final String? cchkIdClientesCheck;
  final Ruc cchkRuc;
  final String? cchkRazon;
  final Select cchkIdOportunidad;
  final String? cchkNombreOportunidad;
  final Select cchkIdContacto;
  final String? cchkNombreContacto;
  final String cchkIdEstadoCheck;
  final String? cchkIdComentario;
  final String cchkIdUsuarioResponsable;
  final String? cchkNombreUsuarioResponsable;
  final String? cchkUbigeo;
  final String? cchkCoordenadaLatitud;
  final String? cchkCoordenadaLongitud;
  final String? cchkDireccionMapa;
  final String? cchkIdUsuarioRegistro;

  CompanyCheckInFormState({
    this.isFormValid = false,
    this.cchkIdClientesCheck,
    this.cchkRuc = const Ruc.dirty(''),
    this.cchkRazon = '',
    this.cchkIdOportunidad = const Select.dirty(''),
    this.cchkIdContacto = const Select.dirty(''),
    this.cchkNombreContacto = '',
    this.cchkNombreOportunidad = '',
    this.cchkCoordenadaLatitud = '',
    this.cchkCoordenadaLongitud = '',
    this.cchkDireccionMapa = '',
    this.cchkIdComentario = '',
    this.cchkIdEstadoCheck = '01',
    this.cchkIdUsuarioRegistro = '',
    this.cchkIdUsuarioResponsable = '',
    this.cchkNombreUsuarioResponsable = '',
    this.cchkUbigeo = ''
  });

  CompanyCheckInFormState copyWith({
    bool? isFormValid,
    String? cchkIdClientesCheck,
    Ruc? cchkRuc,
    String? cchkRazon,
    Select? cchkIdOportunidad,
    String? cchkNombreOportunidad,
    Select? cchkIdContacto,
    String? cchkNombreContacto,
    String? cchkIdEstadoCheck,
    String? cchkIdComentario,
    String? cchkIdUsuarioResponsable,
    String? cchkNombreUsuarioResponsable,
    String? cchkUbigeo,
    String? cchkCoordenadaLatitud,
    String? cchkCoordenadaLongitud,
    String? cchkDireccionMapa,
    String? cchkIdUsuarioRegistro,
  }) =>
      CompanyCheckInFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        cchkRuc: cchkRuc ?? this.cchkRuc,
        cchkRazon: cchkRazon ?? this.cchkRazon,
        cchkCoordenadaLatitud: cchkCoordenadaLatitud ?? this.cchkCoordenadaLatitud,
        cchkCoordenadaLongitud: cchkCoordenadaLongitud ?? this.cchkCoordenadaLongitud,
        cchkDireccionMapa: cchkDireccionMapa ?? this.cchkDireccionMapa,
        cchkIdClientesCheck: cchkIdClientesCheck ?? this.cchkIdClientesCheck,
        cchkIdComentario: cchkIdComentario ?? this.cchkIdComentario,
        cchkIdContacto: cchkIdContacto ?? this.cchkIdContacto,
        cchkNombreContacto: cchkNombreContacto ?? this.cchkNombreContacto,
        cchkNombreOportunidad: cchkNombreOportunidad ?? this.cchkNombreOportunidad,
        cchkIdEstadoCheck: cchkIdEstadoCheck ?? this.cchkIdEstadoCheck,
        cchkIdOportunidad: cchkIdOportunidad ?? this.cchkIdOportunidad,
        cchkIdUsuarioRegistro:
            cchkIdUsuarioRegistro ?? this.cchkIdUsuarioRegistro,
        cchkIdUsuarioResponsable: cchkIdUsuarioResponsable ?? this.cchkIdUsuarioResponsable,
        cchkNombreUsuarioResponsable: cchkNombreUsuarioResponsable ?? this.cchkNombreUsuarioResponsable,
        cchkUbigeo: cchkUbigeo ?? this.cchkUbigeo,
      );
}
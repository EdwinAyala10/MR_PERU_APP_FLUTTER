
import 'package:crm_app/features/companies/domain/entities/create_update_company_local_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final companyLocalFormProvider = StateNotifierProvider.autoDispose
    .family<CompanyLocalFormNotifier, CompanyLocalFormState, CompanyLocal>((ref, companyLocal) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(companiesProvider.notifier).createOrUpdateCompanyLocal;

  return CompanyLocalFormNotifier(
    companyLocal: companyLocal,
    onSubmitCallback: createUpdateCallback,
  );
});

class CompanyLocalFormNotifier extends StateNotifier<CompanyLocalFormState> {
  final Future<CreateUpdateCompanyLocalResponse> Function(
      Map<dynamic, dynamic> companyLocalLike)? onSubmitCallback;

  CompanyLocalFormNotifier({
    this.onSubmitCallback,
    required CompanyLocal companyLocal,
  }) : super(CompanyLocalFormState(
    
    id: companyLocal.id,
    ruc: Ruc.dirty(companyLocal.ruc),
    localDireccion: Address.dirty(companyLocal.localDireccion ?? ''),
    localNombre: Name.dirty(companyLocal.localNombre),
    coordenadasGeo: companyLocal.coordenadasGeo ?? '',
    coordenadasLatitud: companyLocal.coordenadasLatitud ?? '',
    coordenadasLongitud: companyLocal.coordenadasLongitud ?? '',
    departamento: companyLocal.departamento ?? '',
    distrito: companyLocal.distrito ?? '',
    localDepartamento: companyLocal.localDepartamento ?? '',
    localDepartamentoDesc: companyLocal.localDepartamentoDesc ?? '',
    localDistrito: companyLocal.localDistrito ?? '',
    localDistritoDesc: companyLocal.localDistritoDesc ?? '',
    localProvincia: companyLocal.localProvincia ?? '',
    localProvinciaDesc: companyLocal.localProvinciaDesc ?? '',
    localTipo: companyLocal.localTipo ?? '',
    provincia: companyLocal.provincia ?? '',
    ubigeoCodigo: companyLocal.ubigeoCodigo ?? '',
    razon: companyLocal.razon ?? '',
  ));

  Future<CreateUpdateCompanyLocalResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid)
      return CreateUpdateCompanyLocalResponse(
          response: false, message: 'Campos requeridos.');

    if (onSubmitCallback == null)
      return CreateUpdateCompanyLocalResponse(response: false, message: '');

    final companyLocalLike = {
      'LOCAL_CODIGO': (state.id == 'new') ? null : state.id,
      'RUC': state.ruc.value,
      'LOCAL_NOMBRE': state.localNombre.value,
      'LOCAL_DIRECCION': state.localDireccion.value,
      'LOCAL_DEPARTAMENTO': state.localDepartamento,
      'LOCAL_PROVINCIA': state.localProvincia,
      'LOCAL_DISTRITO': state.localDistrito,
      'LOCAL_TIPO': state.localTipo,
      'COORDENADAS_GEO': state.coordenadasGeo,
      'COORDENADAS_LONGITUD': state.coordenadasLongitud,
      'COORDENADAS_LATITUD': state.coordenadasLatitud,
      'UBIGEO_CODIGO': state.ubigeoCodigo,
      'LOCAL_DEPARTAMENTO_DESC': state.localDepartamentoDesc,
      'LOCAL_PROVINCIA_DESC': state.localProvinciaDesc,
      'LOCAL_DISTRITO_DESC': state.localDistritoDesc,
      'RAZON': state.razon,
    };

    try {
      return await onSubmitCallback!(companyLocalLike);
    } catch (e) {
      return CreateUpdateCompanyLocalResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Ruc.dirty(state.ruc.value),
        Name.dirty(state.localNombre.value),
        Address.dirty(state.localDireccion.value),
      ]),
    );
  }

  void onDireccionChanged(String value) {
    state = state.copyWith(
        localDireccion: Address.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Name.dirty(state.localNombre.value),
          Address.dirty(value),
        ]));
  }

  void onNombreChanged(String value) {
    state = state.copyWith(
        localNombre: Name.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Name.dirty(value),
          Address.dirty(state.localDireccion.value),
        ]));
  }

  void onDepartamentoChanged(String id, String value) {
    state = state.copyWith(departamento: id, localDepartamento: value);
  }

  void onTipoChanged(String id, ) {
    state = state.copyWith(localTipo: id, );
  }

  void onDistritoChanged(String id, String value) {
    state = state.copyWith(distrito: id, localDistrito: value);
  }

  void onProvinciaChanged(String id, String value) {
    state = state.copyWith(provincia: id, localProvincia: value);
  }

}

class CompanyLocalFormState {
  final bool isFormValid;
  final String? id;
  final Ruc ruc;
  final Name localNombre;
  final Address localDireccion;
  final String? localDepartamento;
  final String? localProvincia;
  final String? localDistrito;
  final String? localTipo;
  final String? razon;
  final String? coordenadasGeo;
  final String? coordenadasLongitud;
  final String? coordenadasLatitud;
  final String? ubigeoCodigo;
  final String? localDepartamentoDesc;
  final String? localProvinciaDesc;
  final String? localDistritoDesc;
  final String? departamento;
  final String? provincia;
  final String? distrito;

  CompanyLocalFormState({
    this.isFormValid = false,
    this.id,
    this.ruc = const Ruc.dirty(''),
    this.coordenadasGeo = '',
    this.coordenadasLatitud = '',
    this.coordenadasLongitud = '',
    this.departamento = '',
    this.razon = '',
    this.distrito = '',
    this.localDepartamento = '',
    this.localDepartamentoDesc = '',
    this.localDireccion = const Address.dirty(''),
    this.localDistrito = '',
    this.localDistritoDesc = '',
    this.localNombre = const Name.dirty(''),
    this.localProvincia = '',
    this.localProvinciaDesc = '',
    this.localTipo = '',
    this.provincia = '',
    this.ubigeoCodigo = '',
  });

  CompanyLocalFormState copyWith({
    bool? isFormValid,

    String? id,
    Ruc? ruc,
    Name? localNombre,
    Address? localDireccion,
    String? localDepartamento,
    String? localProvincia,
    String? localDistrito,
    String? localTipo,
    String? coordenadasGeo,
    String? razon,
    String? coordenadasLongitud,
    String? coordenadasLatitud,
    String? ubigeoCodigo,
    String? localDepartamentoDesc,
    String? localProvinciaDesc,
    String? localDistritoDesc,
    String? departamento,
    String? provincia,
    String? distrito,
  }) =>
      CompanyLocalFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        coordenadasGeo: coordenadasGeo ?? this.coordenadasGeo,
        coordenadasLatitud: coordenadasLatitud ?? this.coordenadasLatitud,
        coordenadasLongitud: coordenadasLongitud ?? this.coordenadasLongitud,
        departamento: departamento ?? this.departamento,
        distrito: distrito ?? this.distrito,
        localDepartamento: localDepartamento ?? this.localDepartamento,
        razon: razon ?? this.razon,
        localDepartamentoDesc: localDepartamentoDesc ?? this.localDepartamentoDesc,
        localDireccion: localDireccion ?? this.localDireccion,
        localDistrito: localDistrito ?? this.localDistrito,
        localDistritoDesc: localDistritoDesc ?? this.localDistritoDesc,
        localNombre: localNombre ?? this.localNombre,
        localProvincia: localProvincia ?? this.localProvincia,
        localProvinciaDesc: localProvinciaDesc ?? this.localProvinciaDesc,
        localTipo: localTipo ?? this.localTipo,
        provincia: provincia ?? this.provincia,
        ruc: ruc ?? this.ruc,
        ubigeoCodigo: ubigeoCodigo ?? this.ubigeoCodigo,
      );
}

import 'dart:developer';

import '../../../../kpis/domain/entities/array_user.dart';
import '../../../../shared/infrastructure/inputs/inputs.dart';
import '../../../../users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../domain/domain.dart';
import '../providers.dart';
import '../../../../shared/shared.dart';

final opportunityFormProvider = StateNotifierProvider.autoDispose
    .family<OpportunityFormNotifier, OpportunityFormState, Opportunity>(
        (ref, opportunity) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(opportunitiesProvider.notifier).createOrUpdateOpportunity;

  return OpportunityFormNotifier(
    opportunity: opportunity,
    onSubmitCallback: createUpdateCallback,
  );
});

class OpportunityFormNotifier extends StateNotifier<OpportunityFormState> {
  final Future<CreateUpdateOpportunityResponse> Function(
      Map<dynamic, dynamic> opportunityLike)? onSubmitCallback;

  OpportunityFormNotifier({
    this.onSubmitCallback,
    required Opportunity opportunity,
  }) : super(OpportunityFormState(
          id: opportunity.id,
          oprtNombre: Name.dirty(opportunity.oprtNombre),
          oprtEntorno: opportunity.oprtEntorno ?? '',
          optrIdOportunidadIn: opportunity.oprtIdEstadoOportunidad ?? '',
          oprtComentario: opportunity.oprtComentario ?? '',
          oprtFechaPrevistaVenta:
              opportunity.oprtFechaPrevistaVenta ?? DateTime.now(),
          oprtIdEstadoOportunidad:
              StateOpportunity.dirty(opportunity.oprtIdEstadoOportunidad ?? ''),
          oprtIdUsuarioRegistro: opportunity.oprtIdUsuarioRegistro ?? '',
          oprtIdValor: opportunity.oprtIdValor ?? '',
          oprtNobbreEstadoOportunidad:
              opportunity.oprtNobbreEstadoOportunidad ?? '',
          oprtNombreValor: opportunity.oprtNombreValor ?? '',
          oprtLocalNombre: opportunity.oprtLocalNombre ?? '',
          oprtProbabilidad: opportunity.oprtProbabilidad ?? '',
          oprtRuc: EmpresaPrincipal.dirty(opportunity.oprtRuc ?? ''),
          oprtIdContacto: StateContact.dirty(opportunity.oprtIdContacto ?? ''),
          oprtNombreContacto: opportunity.oprtNombreContacto ?? '',
          oprtLocalCodigo: StateLocal.dirty(opportunity.oprtLocalCodigo ?? ''),
          //oprtLocalNombre: opportunity.oprtLocalNombre ?? '',
          oprtRazon: opportunity.oprtRazon ?? '',
          //oprtRucIntermediario01: EmpresaIntermediario.dirty(opportunity.oprtRucIntermediario01 ?? ''),
          oprtRucIntermediario02: opportunity.oprtRucIntermediario02 ?? '',
          opt: opportunity.opt ?? '',
          optrValor: opportunity.oprtValor ?? '0',
          arrayresponsables: opportunity.arrayresponsables ?? [],
          arrayresponsablesEliminar:
              opportunity.arrayresponsablesEliminar ?? [],
        ));

  Future<CreateUpdateOpportunityResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateUpdateOpportunityResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateUpdateOpportunityResponse(response: false, message: '');
    }

    final opportunityLike = {
      'OPRT_ID_OPORTUNIDAD': (state.id == 'new') ? null : state.id,
      'OPRT_NOMBRE': state.oprtNombre.value,
      'OPRT_ENTORNO': 'MR PERU',
      'OPRT_ID_ESTADO_OPORTUNIDAD': state.oprtIdEstadoOportunidad.value,
      'OPRT_PROBABILIDAD': state.oprtProbabilidad,
      'OPRT_ID_VALOR': state.oprtIdValor,
      'OPRT_VALOR': state.optrValor,
      'OPRT_LOCAL_CODIGO': state.oprtLocalCodigo.value,
      'LOCAL_NOMBRE': state.oprtLocalNombre,
      //'OPRT_FECHA_PREVISTA_VENTA': state.oprtFechaPrevistaVenta,
      'OPRT_FECHA_PREVISTA_VENTA':
          "${state.oprtFechaPrevistaVenta?.year.toString().padLeft(4, '0')}-${state.oprtFechaPrevistaVenta?.month.toString().padLeft(2, '0')}-${state.oprtFechaPrevistaVenta?.day.toString().padLeft(2, '0')}",
      'OPRT_RUC': state.oprtRuc.value,
      'RAZON': state.oprtRazon,
      //'OPRT_RUC_INTERMEDIARIO_01': state.oprtRucIntermediario01.value,
      'OPRT_RUC_INTERMEDIARIO_02': state.oprtRucIntermediario02,
      'OPRT_COMENTARIO': state.oprtComentario,
      'OPRT_ID_USUARIO_REGISTRO': state.oprtIdUsuarioRegistro,
      'OPRT_ID_CONTACTO': state.oprtIdContacto.value,
      'OPRT_NOBBRE_ESTADO_OPORTUNIDAD': state.oprtNobbreEstadoOportunidad,
      'OPRT_NOMBRE_VALOR': state.oprtNombreValor,
      'OPRT_ID_PERDIDA_MOTIVO': state.oprtIdPerdidaMotivo,
      'OPT': (state.id == 'new') ? 'INSERT' : 'UPDATE',
      'OPORTUNIDAD_RESPONSABLE': state.arrayresponsables != null
          ? List<dynamic>.from(state.arrayresponsables!.map((x) => x.toJson()))
          : [],
      'OPORTUNIDAD_RESPONSABLE_ELIMINAR':
          state.arrayresponsablesEliminar != null
              ? List<dynamic>.from(
                  state.arrayresponsablesEliminar!.map((x) => x.toJson()))
              : [],
    };
    log("$opportunityLike");
    try {
      return await onSubmitCallback!(opportunityLike);
    } catch (e) {
      return CreateUpdateOpportunityResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Name.dirty(state.oprtNombre.value),
        StateOpportunity.dirty(state.oprtIdEstadoOportunidad.value),
        EmpresaPrincipal.dirty(state.oprtRuc.value),
        StateLocal.dirty(state.oprtLocalCodigo.value),
        //EmpresaIntermediario.dirty(state.oprtRucIntermediario01.value),
        StateContact.dirty(state.oprtIdContacto.value)
      ]),
    );
  }

  void onNameChanged(String value) {
    state = state.copyWith(
        oprtNombre: Name.dirty(value),
        isFormValid: Formz.validate([
          Name.dirty(value),
          StateOpportunity.dirty(state.oprtIdEstadoOportunidad.value),
          EmpresaPrincipal.dirty(state.oprtRuc.value),
          StateLocal.dirty(state.oprtLocalCodigo.value),
          //EmpresaIntermediario.dirty(state.oprtRucIntermediario01.value),
          StateContact.dirty(state.oprtIdContacto.value)
      ]));
  }

  void onIdEstadoChanged(String idEstado) {
    //state = state.copyWith(oprtIdEstadoOportunidad: idEstado);
    log(idEstado);

    state = state.copyWith(
      oprtIdEstadoOportunidad: StateOpportunity.dirty(idEstado),
      isFormValid: Formz.validate([
        Name.dirty(state.oprtNombre.value),
        StateOpportunity.dirty(idEstado),
        EmpresaPrincipal.dirty(state.oprtRuc.value),
        StateLocal.dirty(state.oprtLocalCodigo.value),
        //EmpresaIntermediario.dirty(state.oprtRucIntermediario01.value),
        StateContact.dirty(state.oprtIdContacto.value)
      ]));
  }

  void onNameEstadoChanged(String nameEstado) {
    state = state.copyWith(oprtNobbreEstadoOportunidad: nameEstado);
  }

  void onProbabilidadChanged(String probabilidad) {
    state = state.copyWith(oprtProbabilidad: probabilidad);
  }

  void onIdValorChanged(String idValor) {
    state = state.copyWith(oprtIdValor: idValor);
  }

  void onValorChanged(String valor) {
    state = state.copyWith(oprtNombreValor: valor);
  }

  /*void onImporteTotalChanged(String valor) {
    state = state.copyWith(oprtNombreValor: valor);
  }*/

  void onFechaChanged(DateTime fecha) {
    state = state.copyWith(oprtFechaPrevistaVenta: fecha);
  }

  void onRucChanged(String ruc, String razon) {
    //state = state.copyWith(oprtRuc: ruc, oprtRazon: razon);
    state = state.copyWith(
      oprtRuc: EmpresaPrincipal.dirty(ruc),
      oprtRazon: razon,
      oprtLocalCodigo: const StateLocal.dirty(''),
      oprtLocalNombre: '',
      oprtIdContacto: const StateContact.dirty(''),
      isFormValid: Formz.validate([
        Name.dirty(state.oprtNombre.value),
        StateOpportunity.dirty(state.oprtIdEstadoOportunidad.value),
        EmpresaPrincipal.dirty(ruc),
        //EmpresaIntermediario.dirty(state.oprtRucIntermediario01.value),
        StateLocal.dirty(state.oprtLocalCodigo.value),
        StateContact.dirty(state.oprtIdContacto.value)
      ]));
  }

  /*void onRucIntermediario01Changed(String ruc, String razon) {
    //state = state.copyWith(
    //    oprtRucIntermediario01: ruc, oprtRazonIntermediario01: razon);
    state = state.copyWith(
      oprtRucIntermediario01: EmpresaIntermediario.dirty(ruc),
      oprtRazonIntermediario01: razon,
      isFormValid: Formz.validate([
        Name.dirty(state.oprtNombre.value),
        StateOpportunity.dirty(state.oprtIdEstadoOportunidad.value),
        EmpresaPrincipal.dirty(state.oprtRuc.value),
        EmpresaIntermediario.dirty(ruc),
      ]));
  }*/

  void onRucIntermediario02Changed(String ruc, String razon) {
    state = state.copyWith(
        oprtRucIntermediario02: ruc, oprtRazonIntermediario02: razon);
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(oprtComentario: comentario);
  }

  void onImporteChanged(String valor) {
    state = state.copyWith(optrValor: valor);
  }

  void onLocalChanged(String value, String name) {
    state = state.copyWith(
        oprtLocalCodigo: StateLocal.dirty(value),
        oprtLocalNombre: name,
        isFormValid: Formz.validate([
          Name.dirty(state.oprtNombre.value),
          StateOpportunity.dirty(state.oprtIdEstadoOportunidad.value),
          EmpresaPrincipal.dirty(state.oprtRuc.value),
          StateLocal.dirty(value),
          StateContact.dirty(state.oprtIdContacto.value)
        ]));
  }

  void onContactChanged(String value, String name) {
    state = state.copyWith(
        oprtIdContacto: StateContact.dirty(value),
        oprtNombreContacto: name,
        isFormValid: Formz.validate([
          Name.dirty(state.oprtNombre.value),
          StateOpportunity.dirty(state.oprtIdEstadoOportunidad.value),
          EmpresaPrincipal.dirty(state.oprtRuc.value),
          StateLocal.dirty(state.oprtLocalCodigo.value),
          StateContact.dirty(value)
        ]));
  }

  void onIdPerdidaMotivoChanged(String id) {
    state = state.copyWith(
      oprtIdPerdidaMotivo: id
    );
  }

  void onUsuarioChanged(UserMaster usuario) {
    bool objExist = state.arrayresponsables!
        .any((objeto) => objeto.cresIdUsuarioResponsable == usuario.code);

    if (!objExist) {
      ArrayUser array = ArrayUser();
      array.idResponsable = usuario.id;
      array.cresIdUsuarioResponsable = usuario.code;
      array.userreportName = usuario.name;
      array.nombreResponsable = usuario.name;
      array.oresIdUsuarioResponsable = usuario.code;

      List<ArrayUser> arrayUsuarios = [...state.arrayresponsables ?? [], array];

      state = state.copyWith(arrayresponsables: arrayUsuarios);
    } else {
      state = state;
    }
  }

  void onDeleteUserChanged(ArrayUser item) {
    List<ArrayUser> arrayUsuariosEliminar = [];

    if (state.id != "new") {
      bool objExist = state.arrayresponsablesEliminar!.any((objeto) =>
          objeto.oresIdOportunidadResp == item.oresIdOportunidadResp);

      if (!objExist) {
        ArrayUser array = ArrayUser();
        array.oresIdOportunidadResp = item.oresIdOportunidadResp;

        arrayUsuariosEliminar = [
          ...state.arrayresponsablesEliminar ?? [],
          array
        ];
      }
    }

    List<ArrayUser> arrayUsuarios = [];

    if (state.id == "new") {
      arrayUsuarios = state.arrayresponsables!
          .where((user) =>
              user.cresIdUsuarioResponsable != item.cresIdUsuarioResponsable)
          .toList();
    } else {
      arrayUsuarios = state.arrayresponsables!
          .where((user) =>
              user.oresIdOportunidadResp != item.oresIdOportunidadResp)
          .toList();
    }

    state = state.copyWith(
        arrayresponsables: arrayUsuarios,
        arrayresponsablesEliminar: arrayUsuariosEliminar);
  }
}

class OpportunityFormState {
  final bool isFormValid;
  final String? id;
  final Name oprtNombre;
  final String oprtEntorno;
  final StateOpportunity oprtIdEstadoOportunidad;
  final String oprtProbabilidad;
  final String oprtIdValor;
  final DateTime? oprtFechaPrevistaVenta;
  final EmpresaPrincipal oprtRuc;
  final String oprtRazon;
  final StateLocal oprtLocalCodigo;
  final String? oprtLocalNombre;
  //final EmpresaIntermediario oprtRucIntermediario01;
  final String oprtRazonIntermediario01;
  final String oprtRucIntermediario02;
  final String oprtRazonIntermediario02;
  final String oprtComentario;
  final String oprtIdUsuarioRegistro;
  final String oprtNobbreEstadoOportunidad;
  final String oprtNombreValor;
  final String opt;
  final String optrIdOportunidadIn;
  final String oprtIdPerdidaMotivo;
  final List<ArrayUser>? arrayresponsables;
  final List<ArrayUser>? arrayresponsablesEliminar;
  final String optrValor;
  final StateContact oprtIdContacto;
  final String? oprtNombreContacto;

  OpportunityFormState(
      {this.isFormValid = false,
      this.id,
      this.oprtNombre = const Name.dirty(''),
      this.oprtEntorno = 'MR PERU',
      this.oprtIdEstadoOportunidad = const StateOpportunity.dirty(''),
      this.oprtProbabilidad = '1',
      this.oprtIdValor = '01',
      this.oprtFechaPrevistaVenta,
      this.oprtRuc = const EmpresaPrincipal.dirty(''),
      this.optrValor = '0',
      this.oprtRazon = '',
      this.oprtLocalCodigo = const StateLocal.dirty(''),
      this.oprtLocalNombre = '',
      this.oprtRazonIntermediario01 = '',
      //this.oprtRucIntermediario01 = const EmpresaIntermediario.dirty(''),
      this.oprtRucIntermediario02 = '',
      this.oprtRazonIntermediario02 = '',
      this.oprtComentario = '',
      this.oprtIdUsuarioRegistro = '',
      this.oprtNobbreEstadoOportunidad = '',
      this.oprtIdPerdidaMotivo = '',
      this.oprtNombreValor = '',
      this.opt = '',
      this.arrayresponsables,
      this.arrayresponsablesEliminar,
      this.oprtIdContacto = const StateContact.dirty(''),
      this.oprtNombreContacto = '',
      this.optrIdOportunidadIn = ''});

  OpportunityFormState copyWith({
    bool? isFormValid,
    String? id,
    Name? oprtNombre,
    String? oprtEntorno,
    StateOpportunity? oprtIdEstadoOportunidad,
    String? oprtProbabilidad,
    String? oprtIdValor,
    DateTime? oprtFechaPrevistaVenta,
    EmpresaPrincipal? oprtRuc,
    String? oprtRazon,
    StateLocal? oprtLocalCodigo,
    String? oprtLocalNombre,
    //EmpresaIntermediario? oprtRucIntermediario01,
    String? oprtRazonIntermediario01,
    String? oprtRucIntermediario02,
    String? oprtRazonIntermediario02,
    String? oprtComentario,
    String? oprtIdUsuarioRegistro,
    String? oprtNobbreEstadoOportunidad,
    String? oprtNombreValor,
    String? opt,
    String? optrIdOportunidadIn,
    List<ArrayUser>? arrayresponsables,
    List<ArrayUser>? arrayresponsablesEliminar,
    String? oprtIdPerdidaMotivo,
    String? optrValor,
    StateContact? oprtIdContacto,
    String? oprtNombreContacto,
  }) =>
      OpportunityFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        oprtNombre: oprtNombre ?? this.oprtNombre,
        oprtEntorno: oprtEntorno ?? this.oprtEntorno,
        oprtLocalCodigo: oprtLocalCodigo ?? this.oprtLocalCodigo,
        oprtLocalNombre: oprtLocalNombre ?? this.oprtLocalNombre,
        oprtIdPerdidaMotivo: oprtIdPerdidaMotivo ?? this.oprtIdPerdidaMotivo,
        oprtIdEstadoOportunidad:
            oprtIdEstadoOportunidad ?? this.oprtIdEstadoOportunidad,
        oprtProbabilidad: oprtProbabilidad ?? this.oprtProbabilidad,
        oprtIdValor: oprtIdValor ?? this.oprtIdValor,
        oprtFechaPrevistaVenta:
            oprtFechaPrevistaVenta ?? this.oprtFechaPrevistaVenta,
        oprtRuc: oprtRuc ?? this.oprtRuc,
        optrValor: optrValor ?? this.optrValor,
        oprtRazon: oprtRazon ?? this.oprtRazon,
        //oprtRucIntermediario01:
        //    oprtRucIntermediario01 ?? this.oprtRucIntermediario01,
        oprtRazonIntermediario01:
            oprtRazonIntermediario01 ?? this.oprtRazonIntermediario01,
        oprtRucIntermediario02:
            oprtRucIntermediario02 ?? this.oprtRucIntermediario02,
        oprtRazonIntermediario02:
            oprtRazonIntermediario02 ?? this.oprtRazonIntermediario02,
        oprtComentario: oprtComentario ?? this.oprtComentario,
        oprtIdUsuarioRegistro:
            oprtIdUsuarioRegistro ?? this.oprtIdUsuarioRegistro,
        oprtNobbreEstadoOportunidad:
            oprtNobbreEstadoOportunidad ?? this.oprtNobbreEstadoOportunidad,
        oprtNombreValor: oprtNombreValor ?? this.oprtNombreValor,
        opt: opt ?? this.opt,
        optrIdOportunidadIn: optrIdOportunidadIn ?? this.optrIdOportunidadIn,
        arrayresponsables: arrayresponsables ?? this.arrayresponsables,
        arrayresponsablesEliminar:
            arrayresponsablesEliminar ?? this.arrayresponsablesEliminar,
        oprtIdContacto: oprtIdContacto ?? this.oprtIdContacto,
        oprtNombreContacto: oprtNombreContacto ?? this.oprtNombreContacto,
      );
}

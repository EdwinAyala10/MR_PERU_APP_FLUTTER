import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

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
          oprtIdEstadoOportunidad: opportunity.oprtIdEstadoOportunidad ?? '',
          oprtIdUsuarioRegistro: opportunity.oprtIdUsuarioRegistro ?? '',
          oprtIdValor: opportunity.oprtIdValor ?? '',
          oprtNobbreEstadoOportunidad:
              opportunity.oprtNobbreEstadoOportunidad ?? '',
          oprtNombreValor: opportunity.oprtNombreValor ?? '',
          oprtProbabilidad: opportunity.oprtProbabilidad ?? '',
          oprtRuc: opportunity.oprtRuc ?? '',
          oprtRucIntermediario01: opportunity.oprtRucIntermediario01 ?? '',
          oprtRucIntermediario02: opportunity.oprtRucIntermediario02 ?? '',
          opt: opportunity.opt ?? '',
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
      'OPRT_ID_OPORTUNIDAD': (state.id == 'new') ? '0' : state.id,
      'OPRT_NOMBRE': state.oprtNombre.value,
      'OPRT_ENTORNO': 'MR PERU',
      'OPRT_ID_ESTADO_OPORTUNIDAD': state.oprtIdEstadoOportunidad,
      'OPRT_PROBABILIDAD': state.oprtProbabilidad,
      'OPRT_ID_VALOR': state.oprtIdValor,
      //'OPRT_FECHA_PREVISTA_VENTA': state.oprtFechaPrevistaVenta,
      'OPRT_FECHA_PREVISTA_VENTA':
          "${state.oprtFechaPrevistaVenta?.year.toString().padLeft(4, '0')}-${state.oprtFechaPrevistaVenta?.month.toString().padLeft(2, '0')}-${state.oprtFechaPrevistaVenta?.day.toString().padLeft(2, '0')}",
      'OPRT_RUC': state.oprtRuc,
      'OPRT_RUC_INTERMEDIARIO_01': state.oprtRucIntermediario01,
      'OPRT_RUC_INTERMEDIARIO_02': state.oprtRucIntermediario02,
      'OPRT_COMENTARIO': state.oprtComentario,
      'OPRT_ID_USUARIO_REGISTRO': state.oprtIdUsuarioRegistro,
      'OPRT_NOBBRE_ESTADO_OPORTUNIDAD': state.oprtNobbreEstadoOportunidad,
      'OPRT_NOMBRE_VALOR': state.oprtNombreValor,
      'OPT': (state.id == 'new') ? 'INSERT' : 'UPDATE',
    };

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
      ]),
    );
  }

  void onNameChanged(String value) {
    state = state.copyWith(
        oprtNombre: Name.dirty(value),
        isFormValid: Formz.validate([
          Name.dirty(value),
        ]));
  }

  void onIdEstadoChanged(String idEstado) {
    state = state.copyWith(oprtIdEstadoOportunidad: idEstado);
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
    state = state.copyWith(oprtRuc: ruc, oprtRazon: razon);
  }

  void onRucIntermediario01Changed(String ruc, String razon) {
    state = state.copyWith(
        oprtRucIntermediario01: ruc, oprtRazonIntermediario01: razon);
  }

  void onRucIntermediario02Changed(String ruc, String razon) {
    state = state.copyWith(
        oprtRucIntermediario02: ruc, oprtRazonIntermediario02: razon);
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(oprtComentario: comentario);
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
      bool objExist = state.arrayresponsablesEliminar!
          .any((objeto) => objeto.oresIdOportunidadResp == item.oresIdOportunidadResp);

      if (!objExist) {
        ArrayUser array = ArrayUser();
        array.oresIdOportunidadResp = item.oresIdOportunidadResp;

        arrayUsuariosEliminar = [
          ...state.arrayresponsablesEliminar ?? [],
          array
        ];
      }
    }

    List<ArrayUser> arrayUsuarios = state.arrayresponsables!
        .where((user) => user.oresIdOportunidadResp != item.oresIdOportunidadResp)
        .toList();
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
  final String oprtIdEstadoOportunidad;
  final String oprtProbabilidad;
  final String oprtIdValor;
  final DateTime? oprtFechaPrevistaVenta;
  final String oprtRuc;
  final String oprtRazon;
  final String oprtRucIntermediario01;
  final String oprtRazonIntermediario01;
  final String oprtRucIntermediario02;
  final String oprtRazonIntermediario02;
  final String oprtComentario;
  final String oprtIdUsuarioRegistro;
  final String oprtNobbreEstadoOportunidad;
  final String oprtNombreValor;
  final String opt;
  final String optrIdOportunidadIn;
  final List<ArrayUser>? arrayresponsables;
  final List<ArrayUser>? arrayresponsablesEliminar;

  OpportunityFormState(
      {this.isFormValid = false,
      this.id,
      this.oprtNombre = const Name.dirty(''),
      this.oprtEntorno = 'MR PERU',
      this.oprtIdEstadoOportunidad = '',
      this.oprtProbabilidad = '1',
      this.oprtIdValor = '01',
      this.oprtFechaPrevistaVenta,
      this.oprtRuc = '',
      this.oprtRazon = '',
      this.oprtRazonIntermediario01 = '',
      this.oprtRucIntermediario01 = '',
      this.oprtRucIntermediario02 = '',
      this.oprtRazonIntermediario02 = '',
      this.oprtComentario = '',
      this.oprtIdUsuarioRegistro = '',
      this.oprtNobbreEstadoOportunidad = '',
      this.oprtNombreValor = '',
      this.opt = '',
      this.arrayresponsables,
      this.arrayresponsablesEliminar,
      this.optrIdOportunidadIn = ''});

  OpportunityFormState copyWith({
    bool? isFormValid,
    String? id,
    Name? oprtNombre,
    String? oprtEntorno,
    String? oprtIdEstadoOportunidad,
    String? oprtProbabilidad,
    String? oprtIdValor,
    DateTime? oprtFechaPrevistaVenta,
    String? oprtRuc,
    String? oprtRazon,
    String? oprtRucIntermediario01,
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
  }) =>
      OpportunityFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        oprtNombre: oprtNombre ?? this.oprtNombre,
        oprtEntorno: oprtEntorno ?? this.oprtEntorno,
        oprtIdEstadoOportunidad:
            oprtIdEstadoOportunidad ?? this.oprtIdEstadoOportunidad,
        oprtProbabilidad: oprtProbabilidad ?? this.oprtProbabilidad,
        oprtIdValor: oprtIdValor ?? this.oprtIdValor,
        oprtFechaPrevistaVenta:
            oprtFechaPrevistaVenta ?? this.oprtFechaPrevistaVenta,
        oprtRuc: oprtRuc ?? this.oprtRuc,
        oprtRazon: oprtRazon ?? this.oprtRazon,
        oprtRucIntermediario01:
            oprtRucIntermediario01 ?? this.oprtRucIntermediario01,
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
      );
}

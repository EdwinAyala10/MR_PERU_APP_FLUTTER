import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final kpiFormProvider = StateNotifierProvider.autoDispose
    .family<KpiFormNotifier, KpiFormState, Kpi>(
        (ref, kpi) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(kpisProvider.notifier).createOrUpdateKpi;

  return KpiFormNotifier(
    kpi: kpi,
    onSubmitCallback: createUpdateCallback,
  );
});

class KpiFormNotifier extends StateNotifier<KpiFormState> {
  final Future<CreateUpdateKpiResponse> Function(
      Map<dynamic, dynamic> kpiLike)? onSubmitCallback;

  KpiFormNotifier({
    this.onSubmitCallback,
    required Kpi kpi,
  }) : super(KpiFormState(
          id: kpi.id,

          objrIdAsignacion: kpi.objrIdAsignacion ?? '',
          objrIdCategoria: kpi.objrIdCategoria ?? '',
          objrIdPeriodicidad: kpi.objrIdPeriodicidad ?? '',
          objrIdTipo: kpi.objrIdTipo ?? '',
          objrIdUsuarioRegistro: kpi.objrIdUsuarioRegistro ?? '',
          objrIdUsuarioResponsable: kpi.objrIdUsuarioResponsable ?? '',
          objrNombre: Name.dirty(kpi.objrNombre),
          objrObservaciones: kpi.objrObservaciones ?? '',
        ));

  Future<CreateUpdateKpiResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateUpdateKpiResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateUpdateKpiResponse(response: false, message: '');
    }

    final kpiLike = {
      'OBJR_ID_OBJETIVO': (state.id == 'new') ? '' : state.id,
      'OBJR_NOMBRE': state.objrNombre.value,
      'OBJR_ID_USUARIO_RESPONSABLE': state.objrIdUsuarioResponsable,
      'OBJR_ID_ASIGNACION': state.objrIdAsignacion,
      'OBJR_ID_TIPO': state.objrIdTipo,
      'OBJR_ID_PERIODICIDAD': state.objrIdPeriodicidad,
      'OBJR_OBSERVACIONES': state.objrObservaciones,
      'OBJR_ID_USUARIO_REGISTRO': state.objrIdUsuarioRegistro,
      'OBJR_ID_CATEGORIA': state.objrIdCategoria,
    };

    try {
      return await onSubmitCallback!(kpiLike);
    } catch (e) {
      return CreateUpdateKpiResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Name.dirty(state.objrNombre.value),
      ]),
    );
  }

  void onNombreChanged(String value) {
    state = state.copyWith(
        objrNombre: Name.dirty(value),
        isFormValid: Formz.validate([
          Name.dirty(value),
        ]));
  }

  void onAsignacionChanged(String value, String name) {
    state = state.copyWith(objrIdAsignacion: value, objrNombreAsignacion: name);
  }

  void onCategoriaChanged(String value, String name) {
    state = state.copyWith(objrIdCategoria: value, objrNombreCategoria: name);
  }

  void onTipoChanged(String id, String name) {
    state = state.copyWith(objrIdTipo: id, objrNombreTipo: name);
  }

  void onPeriodicidadChanged(String value, String name) {
    state = state.copyWith(objrIdPeriodicidad: value, objrNombrePeriodicidad: name);
  }

  void onObservacionesChanged(String value) {
    state = state.copyWith(objrObservaciones: value);
  }

}

class KpiFormState {
  final bool isFormValid;
  final String? id;

  final Name objrNombre;
  final String objrIdUsuarioResponsable;
  final String objrNombreUsuarioResponsable;
  final String objrIdAsignacion;
  final String objrNombreAsignacion;
  final String objrIdTipo;
  final String objrNombreTipo;
  final String objrIdPeriodicidad;
  final String objrNombrePeriodicidad;
  final String? objrObservaciones;
  final String objrIdUsuarioRegistro;
  final String objrNombreUsuarioRegistro;
  final String objrIdCategoria;
  final String objrNombreCategoria;

  KpiFormState(
      {this.isFormValid = false,
      this.id,

      this.objrNombre = const Name.dirty(''),
      this.objrIdAsignacion = '',
      this.objrNombreAsignacion = '',
      this.objrIdCategoria = '',
      this.objrNombreCategoria = '',
      this.objrIdPeriodicidad = '',
      this.objrNombrePeriodicidad = '',
      this.objrIdTipo = '',
      this.objrNombreTipo = '',
      this.objrIdUsuarioRegistro = '',
      this.objrNombreUsuarioRegistro = '',
      this.objrIdUsuarioResponsable = '',
      this.objrNombreUsuarioResponsable = '',
      this.objrObservaciones = '',
    });

  KpiFormState copyWith({
    bool? isFormValid,
    String? id,

    Name? objrNombre,
    String? objrIdAsignacion,
    String? objrNombreAsignacion,
    String? objrIdCategoria,
    String? objrNombreCategoria,
    String? objrIdPeriodicidad,
    String? objrNombrePeriodicidad,
    String? objrIdTipo,
    String? objrNombreTipo,

    String? objrIdUsuarioRegistro,
    String? objrNombreUsuarioRegistro,
    String? objrIdUsuarioResponsable,
    String? objrNombreUsuarioResponsable,
    String? objrObservaciones,

  }) =>
      KpiFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,

        objrIdAsignacion: objrIdAsignacion ?? this.objrIdAsignacion,
        objrNombreAsignacion: objrNombreAsignacion ?? this.objrNombreAsignacion,
        objrIdCategoria: objrIdCategoria ?? this.objrIdCategoria,
        objrNombreCategoria: objrNombreCategoria ?? this.objrNombreCategoria,
        objrIdPeriodicidad: objrIdPeriodicidad ?? this.objrIdPeriodicidad,
        objrNombrePeriodicidad: objrNombrePeriodicidad ?? this.objrNombrePeriodicidad,
        objrIdTipo: objrIdTipo ?? this.objrIdTipo,
        objrNombreTipo: objrNombreTipo ?? this.objrNombreTipo,
        objrIdUsuarioRegistro: objrIdUsuarioRegistro ?? this.objrIdUsuarioRegistro,
        objrNombreUsuarioRegistro: objrNombreUsuarioRegistro ?? this.objrNombreUsuarioRegistro,
        objrIdUsuarioResponsable: objrIdUsuarioResponsable ?? this.objrIdUsuarioResponsable,
        objrNombreUsuarioResponsable: objrNombreUsuarioResponsable ?? this.objrNombreUsuarioResponsable,
        objrNombre: objrNombre ?? this.objrNombre,
        objrObservaciones: objrObservaciones ?? this.objrObservaciones,
      );
}

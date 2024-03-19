import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
import 'package:crm_app/features/kpis/domain/entities/periodicidad.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final kpiFormProvider = StateNotifierProvider.autoDispose
    .family<KpiFormNotifier, KpiFormState, Kpi>((ref, kpi) {
  final createUpdateCallback =
      ref.watch(kpisProvider.notifier).createOrUpdateKpi;

  return KpiFormNotifier(
    kpi: kpi,
    onSubmitCallback: createUpdateCallback,
  );
});

class KpiFormNotifier extends StateNotifier<KpiFormState> {
  final Future<CreateUpdateKpiResponse> Function(Map<dynamic, dynamic> kpiLike)?
      onSubmitCallback;

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
          objrNombreAsignacion: kpi.objrNombreAsignacion ?? '',
          objrNombreCategoria: kpi.objrNombreCategoria ?? '',
          objrNombrePeriodicidad: kpi.objrNombrePeriodicidad ?? '',
          objrNombreTipo: kpi.objrNombreTipo ?? '',
          objrNombreUsuarioRegistro: kpi.objrNombreUsuarioRegistro ?? '',
          objrNombreUsuarioResponsable: kpi.objrNombreUsuarioResponsable ?? '',
          objrCantidad: kpi.objrCantidad ?? '',
          arrayuserasignacion: kpi.arrayuserasignacion ?? [],
          peobIdPeriodicidad: kpi.peobIdPeriodicidad ?? [],
        ));

  Future<CreateUpdateKpiResponse> onFormSubmit() async {
    print('LLEGO ONFORMSUBMIT');
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateUpdateKpiResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateUpdateKpiResponse(response: false, message: '');
    }

    final kpiLike = {
      'OBJR_ID_OBJETIVO': (state.id == 'new') ? null : state.id,
      'OBJR_NOMBRE': state.objrNombre.value,
      'OBJR_ID_USUARIO_RESPONSABLE': state.objrIdUsuarioResponsable,
      'OBJR_ID_ASIGNACION': state.objrIdAsignacion,
      'OBJR_ID_TIPO': state.objrIdTipo,
      'OBJR_ID_PERIODICIDAD': state.objrIdPeriodicidad,
      'OBJR_OBSERVACIONES': state.objrObservaciones,
      'OBJR_ID_USUARIO_REGISTRO': state.objrIdUsuarioRegistro,
      'OBJR_ID_CATEGORIA': state.objrIdCategoria,
      'OBJR_NOMNRE_ASIGNACION': state.objrNombreAsignacion,
      'OBJR_NOMNRE_CATEGORIA': state.objrIdCategoria,
      'OBJR_NOMNRE_TIPO': state.objrNombreTipo,
      'OBJR_CANTIDAD': state.objrCantidad,
      'OBJR_NOMNRE_PERIODICIDAD': state.objrNombrePeriodicidad,
      'ARRAYUSERASIGNACION': state.arrayuserasignacion != null
          ? List<dynamic>.from(
              state.arrayuserasignacion!.map((x) => x.toJson()))
          : [],
      'PEOB_ID_PERIODICIDAD': state.peobIdPeriodicidad != null
          ? List<dynamic>.from(state.peobIdPeriodicidad!.map((x) => x.toJson()))
          : [],
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
    state =
        state.copyWith(objrIdPeriodicidad: value, objrNombrePeriodicidad: name);
  }

  void onObservacionesChanged(String value) {
    state = state.copyWith(objrObservaciones: value);
  }

  void onCantidadChanged(String value) {
    List<Periodicidad> newPeriodicidades = state.peobIdPeriodicidad!;

    for (int i = 0; i < newPeriodicidades.length; i++) {
      newPeriodicidades[i].peobCantidad = value;
    }

    state = state.copyWith(objrCantidad: value, peobIdPeriodicidad: newPeriodicidades);
  }

  void onCantidadPorMesChanged(String cantidad, Periodicidad periodicidad) {
    List<Periodicidad> newPeriodicidades = List.from(state.peobIdPeriodicidad!);

    // Buscar el índice del objeto Periodicidad en la lista
    int index = newPeriodicidades.indexWhere((p) => p == periodicidad);

    // Verificar si se encontró el objeto en la lista
    if (index != -1) {
      // Crear un nuevo objeto Periodicidad con el campo 'peobCantidad' actualizado
      Periodicidad updatedPeriodicidad = Periodicidad(
        periIdPeriodicidad: periodicidad.periIdPeriodicidad,
        peobIdPeriodicidad: periodicidad.peobIdPeriodicidad,
        periCodigo: periodicidad.periCodigo,
        periNombre: periodicidad.periNombre,
        peobCantidad: cantidad,
      );

      // Reemplazar el objeto original con el nuevo objeto actualizado
      newPeriodicidades[index] = updatedPeriodicidad;
    }

    state = state.copyWith(objrCantidad: cantidad, peobIdPeriodicidad: newPeriodicidades);
  }

  void onCheckDifMesChanged(bool bol) {
    state = state.copyWith(objrValorDifMes: bol);
  }

  void onUsuarioChanged(UserMaster usuario) {
    bool objExist = state.arrayuserasignacion!.any(
        (objeto) => objeto.id == usuario.id && objeto.name == usuario.name);

    if (!objExist) {
      ArrayUser array = ArrayUser();
      array.id = usuario.id;
      array.name = usuario.name;

      List<ArrayUser> arrayUsuarios = [
        ...state.arrayuserasignacion ?? [],
        array
      ];

      state = state.copyWith(arrayuserasignacion: arrayUsuarios);
    } else {
      state = state;
    }
  }

  void onDeleteUserChanged(ArrayUser item) {
    List<ArrayUser> arrayUsuarios =
        state.arrayuserasignacion!.where((user) => user.id != item.id).toList();
    state = state.copyWith(arrayuserasignacion: arrayUsuarios);
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
  final String objrCantidad;
  final bool objrValorDifMes;
  final List<ArrayUser>? arrayuserasignacion;
  final List<Periodicidad>? peobIdPeriodicidad;

  KpiFormState({
    this.isFormValid = false,
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
    this.objrCantidad = '',
    this.objrValorDifMes = false,
    this.arrayuserasignacion,
    this.peobIdPeriodicidad,
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
    String? objrCantidad,
    String? objrIdUsuarioRegistro,
    String? objrNombreUsuarioRegistro,
    String? objrIdUsuarioResponsable,
    String? objrNombreUsuarioResponsable,
    String? objrObservaciones,
    bool? objrValorDifMes,
    List<ArrayUser>? arrayuserasignacion,
    List<Periodicidad>? peobIdPeriodicidad,
  }) =>
      KpiFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        objrIdAsignacion: objrIdAsignacion ?? this.objrIdAsignacion,
        objrNombreAsignacion: objrNombreAsignacion ?? this.objrNombreAsignacion,
        objrIdCategoria: objrIdCategoria ?? this.objrIdCategoria,
        objrNombreCategoria: objrNombreCategoria ?? this.objrNombreCategoria,
        objrIdPeriodicidad: objrIdPeriodicidad ?? this.objrIdPeriodicidad,
        objrNombrePeriodicidad:
            objrNombrePeriodicidad ?? this.objrNombrePeriodicidad,
        objrIdTipo: objrIdTipo ?? this.objrIdTipo,
        objrNombreTipo: objrNombreTipo ?? this.objrNombreTipo,
        objrIdUsuarioRegistro:
            objrIdUsuarioRegistro ?? this.objrIdUsuarioRegistro,
        objrNombreUsuarioRegistro:
            objrNombreUsuarioRegistro ?? this.objrNombreUsuarioRegistro,
        objrIdUsuarioResponsable:
            objrIdUsuarioResponsable ?? this.objrIdUsuarioResponsable,
        objrNombreUsuarioResponsable:
            objrNombreUsuarioResponsable ?? this.objrNombreUsuarioResponsable,
        objrNombre: objrNombre ?? this.objrNombre,
        objrObservaciones: objrObservaciones ?? this.objrObservaciones,
        objrValorDifMes: objrValorDifMes ?? this.objrValorDifMes,
        arrayuserasignacion: arrayuserasignacion ?? this.arrayuserasignacion,
        peobIdPeriodicidad: peobIdPeriodicidad ?? this.peobIdPeriodicidad,
        objrCantidad: objrCantidad ?? this.objrCantidad,
      );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final activityFormProvider = StateNotifierProvider.autoDispose
    .family<ActivityFormNotifier, ActivityFormState, Activity>(
        (ref, activity) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(activitiesProvider.notifier).createOrUpdateActivity;

  return ActivityFormNotifier(
    activity: activity,
    onSubmitCallback: createUpdateCallback,
  );
});

class ActivityFormNotifier extends StateNotifier<ActivityFormState> {
  final Future<CreateUpdateActivityResponse> Function(
      Map<dynamic, dynamic> activityLike)? onSubmitCallback;

  ActivityFormNotifier({
    this.onSubmitCallback,
    required Activity activity,
  }) : super(ActivityFormState(
          id: activity.id,
          actiComentario: activity.actiComentario ?? '',
          actiEstadoReg: activity.actiEstadoReg ?? '',
          actiFechaActividad: activity.actiFechaActividad ?? DateTime.now(),
          actiHoraActividad: activity.actiHoraActividad ?? '',
          actiIdActividadIn: activity.actiIdActividadIn ?? '',
          actiIdContacto: Contacto.dirty(activity.actiIdContacto),
          actiIdOportunidad: activity.actiIdOportunidad ?? '',
          actiIdTipoGestion: TipoGestion.dirty(activity.actiIdTipoGestion),
          actiIdUsuarioActualizacion: activity.actiIdUsuarioActualizacion ?? '',
          actiIdUsuarioRegistro: activity.actiIdUsuarioRegistro ?? '',
          actiIdUsuarioResponsable: activity.actiIdUsuarioResponsable ?? '',
          actiNombreArchivo: activity.actiNombreArchivo ?? '',
          actiNombreOportunidad: activity.actiNombreOportunidad ?? '',
          actiNombreTipoGestion: activity.actiNombreTipoGestion ?? '',
          actiRuc: Ruc.dirty(activity.actiRuc),
          actiNombreResponsable: activity.actiNombreResponsable ?? '',
          opt: activity.opt ?? '',
        ));

  Future<CreateUpdateActivityResponse> onFormSubmit() async {
    print('QUE PASO');
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateUpdateActivityResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateUpdateActivityResponse(response: false, message: '');
    }

    final activityLike = {
      'ACTI_ID_ACTIVIDAD_IN': (state.id == 'new') ? '0' : state.id,
      'ACTI_NOMBRE_RESPONSABLE': state.actiNombreResponsable,
      'ACTI_ID_USUARIO_RESPONSABLE': state.actiIdUsuarioResponsable,
      'ACTI_ID_TIPO_GESTION': state.actiIdTipoGestion.value,
      //'ACTI_FECHA_ACTIVIDAD': state.actiFechaActividad,
      "ACTI_FECHA_ACTIVIDAD": "${state.actiFechaActividad?.year.toString().padLeft(4, '0')}-${state.actiFechaActividad?.month.toString().padLeft(2, '0')}-${state.actiFechaActividad?.day.toString().padLeft(2, '0')}",
      'ACTI_HORA_ACTIVIDAD': state.actiHoraActividad,
      'ACTI_RUC': state.actiRuc.value,
      'ACTI_ID_OPORTUNIDAD': state.actiIdOportunidad,
      'ACTI_ID_CONTACTO': state.actiIdContacto.value,
      'ACTI_COMENTARIO': state.actiComentario,
      'ACTI_NOMBRE_ARCHIVO': state.actiNombreArchivo,
      'ACTI_ID_USUARIO_REGISTRO': state.actiIdUsuarioRegistro,
      'OPT': (state.id == 'new') ? 'INSERT' : 'UPDATE',
      'ACTI_NOMBRE_TIPO_GESTION': state.actiNombreTipoGestion,
      'ACTI_NOMBRE_OPORTUNIDAD': state.actiNombreOportunidad,
    };

    try {
      return await onSubmitCallback!(activityLike);
    } catch (e) {
      return CreateUpdateActivityResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Ruc.dirty(state.actiRuc.value),
        TipoGestion.dirty(state.actiIdTipoGestion.value),
        Contacto.dirty(state.actiIdContacto.value),
      ]),
    );
  }

  void onRucChanged(String value, String name) {
    state = state.copyWith(
        actiRuc: Ruc.dirty(value),
        actiRazon: name,
        isFormValid: Formz.validate([
          Ruc.dirty(value),
          TipoGestion.dirty(state.actiIdTipoGestion.value),
          Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  void onContactoChanged(String value, String name) {
    state = state.copyWith(
        actiIdContacto: Contacto.dirty(value),
        actiNombreContacto: name,
        isFormValid: Formz.validate([
          Ruc.dirty(state.actiIdContacto.value),
          TipoGestion.dirty(value),
          Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  void onTipoGestionChanged(String value, String name) {
    state = state.copyWith(
        actiIdTipoGestion: TipoGestion.dirty(value),
        actiNombreTipoGestion: name,
        isFormValid: Formz.validate([
          Ruc.dirty(state.actiRuc.value),
          TipoGestion.dirty(value),
          Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  void onFechaChanged(DateTime fecha) {
    state = state.copyWith(actiFechaActividad: fecha);
  }

  void onHoraChanged(String hora) {
    state = state.copyWith(actiHoraActividad: hora);
  }

  void onOportunidadChanged(String id, String nombre) {
    state = state.copyWith(actiIdOportunidad: id, actiNombreOportunidad: nombre);
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(actiComentario: comentario);
  }

  void onResponsableChanged(String id, String nombre) {
    state = state.copyWith(actiIdUsuarioResponsable: id, actiNombreResponsable: nombre);
  }

}

class ActivityFormState {
  final bool isFormValid;
  final String? id;

  final String actiIdUsuarioResponsable;
  final TipoGestion actiIdTipoGestion;
  final DateTime? actiFechaActividad;
  final String actiHoraActividad;
  final Ruc actiRuc;
  final String actiRazon;
  final String actiIdOportunidad;
  final Contacto actiIdContacto;
  final String actiNombreContacto;
  final String actiComentario;
  final String actiNombreArchivo;
  final String actiIdUsuarioRegistro;
  final String actiEstadoReg;
  final String actiNombreTipoGestion;
  final String actiNombreOportunidad;
  final String actiIdUsuarioActualizacion;
  final String opt;
  final String actiIdActividadIn;
  final String actiNombreResponsable;

  ActivityFormState(
      {this.isFormValid = false,
      this.id,

      this.actiComentario = '',
      this.actiEstadoReg = '',
      this.actiFechaActividad,
      this.actiHoraActividad = '',
      this.actiIdActividadIn = '',
      this.actiIdContacto = const Contacto.dirty(''),
      this.actiNombreContacto = '',
      this.actiIdOportunidad = '',
      this.actiIdTipoGestion = const TipoGestion.dirty(''),
      this.actiIdUsuarioActualizacion = '',
      this.actiIdUsuarioRegistro = '',
      this.actiIdUsuarioResponsable = '',
      this.actiNombreArchivo = '',
      this.actiNombreOportunidad = '',
      this.actiNombreTipoGestion = '',
      this.actiNombreResponsable = '',
      this.actiRuc = const Ruc.dirty(''),
      this.actiRazon = '',
      this.opt = ''});

  ActivityFormState copyWith({
    bool? isFormValid,
    String? id,

    String? actiIdUsuarioResponsable,
    TipoGestion? actiIdTipoGestion,
    DateTime? actiFechaActividad,
    String? actiHoraActividad,
    Ruc? actiRuc,
    String? actiRazon,
    String? actiIdOportunidad,
    Contacto? actiIdContacto,
    String? actiNombreContacto,
    String? actiComentario,
    String? actiNombreArchivo,
    String? actiIdUsuarioRegistro,
    String? actiEstadoReg,
    String? actiNombreTipoGestion,
    String? actiNombreOportunidad,
    String? actiIdUsuarioActualizacion,
    String? opt,
    String? actiNombreResponsable,
    String? actiIdActividadIn
  }) =>
      ActivityFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        actiComentario: actiComentario ?? this.actiComentario,
        actiEstadoReg: actiEstadoReg ?? this.actiEstadoReg,
        actiFechaActividad: actiFechaActividad ?? this.actiFechaActividad,
        actiHoraActividad: actiHoraActividad ?? this.actiHoraActividad,
        actiIdActividadIn: actiIdActividadIn ?? this.actiIdActividadIn,
        actiIdContacto: actiIdContacto ?? this.actiIdContacto,
        actiNombreContacto: actiNombreContacto ?? this.actiNombreContacto,
        actiIdOportunidad: actiIdOportunidad ?? this.actiIdOportunidad,
        actiIdTipoGestion: actiIdTipoGestion ?? this.actiIdTipoGestion,
        actiIdUsuarioActualizacion: actiIdUsuarioActualizacion ?? this.actiIdUsuarioActualizacion,
        actiIdUsuarioRegistro: actiIdUsuarioRegistro ?? this.actiIdUsuarioRegistro,
        actiIdUsuarioResponsable: actiIdUsuarioResponsable ?? this.actiIdUsuarioResponsable,
        actiNombreArchivo: actiNombreArchivo ?? this.actiNombreArchivo,
        actiNombreOportunidad: actiNombreOportunidad ?? this.actiNombreOportunidad,
        actiNombreTipoGestion: actiNombreTipoGestion ?? this.actiNombreTipoGestion,
        actiRuc: actiRuc ?? this.actiRuc,
        actiRazon: actiRazon ?? this.actiRazon,
        actiNombreResponsable: actiNombreResponsable ?? this.actiNombreResponsable,
        opt: opt ?? this.opt,
      );
}

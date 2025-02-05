import 'package:crm_app/features/opportunities/domain/domain.dart';

import '../../../../contacts/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../domain/domain.dart';
import '../providers.dart';
import '../../../../shared/shared.dart';

final selectOpportunity = StateProvider<Opportunity?>((ref) => null);

final activityFormProvider = StateNotifierProvider.autoDispose
    .family<ActivityFormNotifier, ActivityFormState, Activity>((ref, activity) {
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
          actiComentario: activity.actiComentario,
          actiEstadoReg: activity.actiEstadoReg,
          actiFechaActividad: activity.actiFechaActividad,
          actiHoraActividad: activity.actiHoraActividad,
          actiIdActividadIn: activity.actiIdActividadIn ?? '',
          contactoDesc: activity.contactoDesc ?? '',
          //actiIdContacto: Contacto.dirty(activity.actiIdContacto),
          actiIdOportunidad: Oportunidad.dirty(activity.actiIdOportunidad),
          actiIdTipoGestion: TipoGestion.dirty(activity.actiIdTipoGestion),
          actiIdUsuarioActualizacion: activity.actiIdUsuarioActualizacion ?? '',
          actiIdUsuarioRegistro: activity.actiIdUsuarioRegistro,
          actiIdUsuarioResponsable: activity.actiIdUsuarioResponsable,
          actiNombreArchivo: activity.actiNombreArchivo,
          actiNombreOportunidad: activity.actiNombreOportunidad,
          actiNombreTipoGestion: activity.actiNombreTipoGestion,
          actiIdTipoRegistro: activity.actiIdTipoRegistro,
          actiRuc: StateCompany.dirty(activity.actiRuc),
          actiRazon: activity.actiRazon ?? '',
          actiNombreResponsable: activity.actiNombreResponsable ?? '',
          opt: activity.opt ?? '',
          actividadesContacto: activity.actividadesContacto ?? [],
          actividadesContactoEliminar:
              activity.actividadesContactoEliminar ?? [],
        ));

  Future<CreateUpdateActivityResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateUpdateActivityResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateUpdateActivityResponse(response: false, message: '');
    }

    final activityLike = {
      'ACTI_ID_ACTIVIDAD': (state.id == 'new') ? null : state.id,
      'ACTI_NOMBRE_RESPONSABLE': state.actiNombreResponsable,
      'ACTI_ID_USUARIO_RESPONSABLE': state.actiIdUsuarioResponsable,
      'ACTI_ID_TIPO_GESTION': state.actiIdTipoGestion.value,
      //'ACTI_ID_TIPO_REGISTRO': '02',

      //'ACTI_FECHA_ACTIVIDAD': state.actiFechaActividad,
      "ACTI_FECHA_ACTIVIDAD":
          "${state.actiFechaActividad?.year.toString().padLeft(4, '0')}-${state.actiFechaActividad?.month.toString().padLeft(2, '0')}-${state.actiFechaActividad?.day.toString().padLeft(2, '0')}",
      'ACTI_HORA_ACTIVIDAD': state.actiHoraActividad,
      'ACTI_RUC': state.actiRuc.value,
      'ACTI_RAZON': state.actiRazon,
      'ACTI_ID_TIPO_REGISTRO': state.actiIdTipoRegistro,
      'ACTI_ID_OPORTUNIDAD': state.actiIdOportunidad.value,
      //'ACTI_ID_CONTACTO': state.actiIdContacto.value,
      'ACTI_ID_CONTACTO': state.actividadesContacto?[0].acntIdContacto ?? '',
      'ACTI_COMENTARIO': state.actiComentario,
      'ACTI_NOMBRE_ARCHIVO': state.actiNombreArchivo,
      'ACTI_ID_USUARIO_REGISTRO': state.actiIdUsuarioRegistro,
      'OPT': (state.id == 'new') ? 'INSERT' : 'UPDATE',
      'ACTI_NOMBRE_TIPO_GESTION': state.actiNombreTipoGestion,
      'CONTACTO_DESC': state.contactoDesc,
      'ACTI_NOMBRE_OPORTUNIDAD': state.actiNombreOportunidad,
      'ACTIVIDADES_CONTACTO': state.actividadesContacto != null
          ? List<dynamic>.from(
              state.actividadesContacto!.map((x) => x.toJson()))
          : [],
      'ACTIVIDADES_CONTACTO_ELIMINAR': state.actividadesContactoEliminar != null
          ? List<dynamic>.from(
              state.actividadesContactoEliminar!.map((x) => x.toJson()))
          : [],
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
        StateCompany.dirty(state.actiRuc.value),
        TipoGestion.dirty(state.actiIdTipoGestion.value),
        Oportunidad.dirty(state.actiIdOportunidad.value)
        //Contacto.dirty(state.actiIdContacto.value),
      ]),
    );
  }

  void onRucChanged(String value, String name) {
    state = state.copyWith(
        actiRuc: StateCompany.dirty(value),
        actiRazon: name,
        actiIdOportunidad: Oportunidad.dirty(''),
        actividadesContacto: [],
        isFormValid: Formz.validate([
          StateCompany.dirty(value),
          TipoGestion.dirty(state.actiIdTipoGestion.value),
          //Oportunidad.dirty(state.actiIdOportunidad.value),
          //Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  /*void onContactoChanged(String value, String name) {
    state = state.copyWith(
        actiIdContacto: Contacto.dirty(value),
        actiNombreContacto: name,
        isFormValid: Formz.validate([
          Ruc.dirty(state.actiIdContacto.value),
          TipoGestion.dirty(value),
          Contacto.dirty(state.actiIdContacto.value)
        ]));
  }*/

  void onTipoGestionChanged(String value, String name) {
    state = state.copyWith(
        actiIdTipoGestion: TipoGestion.dirty(value),
        actiNombreTipoGestion: name,
        isFormValid: Formz.validate([
          StateCompany.dirty(state.actiRuc.value),
          TipoGestion.dirty(value),
          Oportunidad.dirty(state.actiIdOportunidad.value)
          //Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  void onFechaChanged(DateTime fecha) {
    state = state.copyWith(actiFechaActividad: fecha);
  }

  void onHoraChanged(String hora) {
    state = state.copyWith(actiHoraActividad: hora);
  }

  void onOportunidadChanged(String id, String nombre) {
    state = state.copyWith(
        actiIdOportunidad: Oportunidad.dirty(id),
        actiNombreOportunidad: nombre,
        isFormValid: Formz.validate([
          StateCompany.dirty(state.actiRuc.value),
          TipoGestion.dirty(state.actiIdTipoGestion.value),
          Oportunidad.dirty(id)
          //Contacto.dirty(state.actiIdContacto.value)
        ]));
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(actiComentario: comentario);
  }

  void onResponsableChanged(String id, String nombre) {
    state = state.copyWith(
        actiIdUsuarioResponsable: id, actiNombreResponsable: nombre);
  }

  void onContactoChanged(Contact contacto) {
    bool objExist = state.actividadesContacto!
        .any((objeto) => objeto.acntIdContacto == contacto.id);

    if (!objExist) {
      ContactArray array = ContactArray();
      array.acntIdContacto = contacto.id;
      array.nombre = contacto.contactoDesc;
      array.contactoDesc = contacto.contactoDesc;

      List<ContactArray> arrayContactos = [
        ...state.actividadesContacto ?? [],
        array
      ];

      state = state.copyWith(actividadesContacto: arrayContactos);
    } else {
      state = state;
    }
  }

  void onDeleteContactoChanged(ContactArray item) {
    List<ContactArray> arrayContactosEliminar = [];

    if (state.id != "new") {
      bool objExist = state.actividadesContactoEliminar!.any((objeto) =>
          objeto.acntIdActividadContacto == item.acntIdActividadContacto);

      if (!objExist) {
        ContactArray array = ContactArray();
        array.acntIdActividadContacto = item.acntIdActividadContacto;

        arrayContactosEliminar = [
          ...state.actividadesContactoEliminar ?? [],
          array
        ];
      }
    }

    List<ContactArray> arrayContactos = [];

    if (state.id == "new") {
      arrayContactos = state.actividadesContacto!
          .where((contact) => contact.acntIdContacto != item.acntIdContacto)
          .toList();
    } else {
      arrayContactos = state.actividadesContacto!
          .where((contact) =>
              contact.acntIdActividadContacto != item.acntIdActividadContacto)
          .toList();
    }

    state = state.copyWith(
        actividadesContacto: arrayContactos,
        actividadesContactoEliminar: arrayContactosEliminar);
  }
}

class ActivityFormState {
  final bool isFormValid;
  final String? id;

  final String actiIdUsuarioResponsable;
  final TipoGestion actiIdTipoGestion;
  final DateTime? actiFechaActividad;
  final String actiHoraActividad;
  final StateCompany actiRuc;
  final String actiRazon;
  final Oportunidad actiIdOportunidad;
  //final Contacto actiIdContacto;
  final String actiNombreContacto;
  final String actiComentario;
  final String actiNombreArchivo;
  final String actiIdUsuarioRegistro;
  final String actiEstadoReg;
  final String actiNombreTipoGestion;
  final String actiNombreOportunidad;
  final String actiIdUsuarioActualizacion;
  final String opt;
  final String contactoDesc;
  final String actiIdActividadIn;
  final String actiNombreResponsable;
  final List<ContactArray>? actividadesContacto;
  final List<ContactArray>? actividadesContactoEliminar;
  final String? actiIdTipoRegistro;

  ActivityFormState(
      {this.isFormValid = false,
      this.id,
      this.actiComentario = '',
      this.actiEstadoReg = '',
      this.actiFechaActividad,
      this.actiHoraActividad = '',
      this.actiIdActividadIn = '',
      //this.actiIdContacto = const Contacto.dirty(''),
      this.actiNombreContacto = '',
      this.actividadesContacto,
      this.actiIdOportunidad = const Oportunidad.dirty(''),
      this.actiIdTipoGestion = const TipoGestion.dirty(''),
      this.actiIdUsuarioActualizacion = '',
      this.actiIdUsuarioRegistro = '',
      this.actiIdUsuarioResponsable = '',
      this.actiNombreArchivo = '',
      this.actiIdTipoRegistro = '',
      this.actiNombreOportunidad = '',
      this.actiNombreTipoGestion = '',
      this.actiNombreResponsable = '',
      this.actiRuc = const StateCompany.dirty(''),
      this.actiRazon = '',
      this.contactoDesc = '',
      this.actividadesContactoEliminar,
      this.opt = ''});

  ActivityFormState copyWith(
          {bool? isFormValid,
          String? id,
          String? actiIdUsuarioResponsable,
          TipoGestion? actiIdTipoGestion,
          DateTime? actiFechaActividad,
          String? actiHoraActividad,
          StateCompany? actiRuc,
          String? actiRazon,
          String? actiIdTipoRegistro,
          Oportunidad? actiIdOportunidad,
          //Contacto? actiIdContacto,
          String? actiNombreContacto,
          String? actiComentario,
          String? actiNombreArchivo,
          String? actiIdUsuarioRegistro,
          String? actiEstadoReg,
          String? actiNombreTipoGestion,
          String? actiNombreOportunidad,
          String? actiIdUsuarioActualizacion,
          String? opt,
          String? contactoDesc,
          String? actiNombreResponsable,
          String? actiIdActividadIn,
          List<ContactArray>? actividadesContacto,
          List<ContactArray>? actividadesContactoEliminar}) =>
      ActivityFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        actiIdTipoRegistro: actiIdTipoRegistro ?? this.actiIdTipoRegistro,
        actiComentario: actiComentario ?? this.actiComentario,
        actividadesContacto: actividadesContacto ?? this.actividadesContacto,
        actividadesContactoEliminar:
            actividadesContactoEliminar ?? this.actividadesContactoEliminar,
        actiEstadoReg: actiEstadoReg ?? this.actiEstadoReg,
        actiFechaActividad: actiFechaActividad ?? this.actiFechaActividad,
        actiHoraActividad: actiHoraActividad ?? this.actiHoraActividad,
        actiIdActividadIn: actiIdActividadIn ?? this.actiIdActividadIn,
        //actiIdContacto: actiIdContacto ?? this.actiIdContacto,
        actiNombreContacto: actiNombreContacto ?? this.actiNombreContacto,
        actiIdOportunidad: actiIdOportunidad ?? this.actiIdOportunidad,
        actiIdTipoGestion: actiIdTipoGestion ?? this.actiIdTipoGestion,
        actiIdUsuarioActualizacion:
            actiIdUsuarioActualizacion ?? this.actiIdUsuarioActualizacion,
        actiIdUsuarioRegistro:
            actiIdUsuarioRegistro ?? this.actiIdUsuarioRegistro,
        actiIdUsuarioResponsable:
            actiIdUsuarioResponsable ?? this.actiIdUsuarioResponsable,
        actiNombreArchivo: actiNombreArchivo ?? this.actiNombreArchivo,
        actiNombreOportunidad:
            actiNombreOportunidad ?? this.actiNombreOportunidad,
        actiNombreTipoGestion:
            actiNombreTipoGestion ?? this.actiNombreTipoGestion,
        actiRuc: actiRuc ?? this.actiRuc,
        actiRazon: actiRazon ?? this.actiRazon,
        contactoDesc: contactoDesc ?? this.contactoDesc,
        actiNombreResponsable:
            actiNombreResponsable ?? this.actiNombreResponsable,
        opt: opt ?? this.opt,
      );
}

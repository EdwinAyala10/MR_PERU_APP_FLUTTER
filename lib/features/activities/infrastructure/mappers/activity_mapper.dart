import 'package:crm_app/features/activities/domain/domain.dart';


class ActivityMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Activity(
    id: json['ACTI_ID_ACTIVIDAD'] ?? '',
    actiComentario: json['ACTI_COMENTARIO'] ?? '',
    actiEstadoReg: json['ACTI_ESTADO_REG'] ?? '',
    actiFechaActividad: DateTime.parse(json["ACTI_FECHA_ACTIVIDAD"]),
    actiHoraActividad: json['ACTI_HORA_ACTIVIDAD'] ?? '',
    actiIdContacto: json['ACTI_ID_CONTACTO'] ?? '',
    actiIdOportunidad: json['ACTI_ID_OPORTUNIDAD'] ?? '',
    actiIdTipoGestion: json['ACTI_ID_TIPO_GESTION'] ?? '',
    actiIdUsuarioRegistro: json['ACTI_ID_USUARIO_REGISTRO'] ?? '',
    actiIdUsuarioResponsable: json['ACTI_ID_USUARIO_RESPONSABLE'] ?? '',
    actiNombreArchivo: json['ACTI_NOMBRE_ARCHIVO'] ?? '',
    actiNombreOportunidad: json['ACTI_NOMBRE_OPORTUNIDAD'] ?? '',
    actiNombreTipoGestion: json['ACTI_NOMBRE_TIPO_GESTION'] ?? '',
    actiRuc: json['ACTI_RUC'] ?? '',
    actiIdUsuarioActualizacion: json['ACTI_ID_USUARIO_ACTUALIZACION'] ?? '',

    actiIdActividadIn: json['ACTI_ID_ACTIVIDAD_IN'] ?? '',
    opt: json['OPT'] ?? '',
  );

}

import '../../domain/domain.dart';
import '../../../contacts/domain/domain.dart';


class EventMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Event(
    id: json['EVNT_ID_EVENTO'] ?? '',

    arraycontacto: json["EVENTOS_INVITACION_CONTACTO"] != null ? List<ContactArray>.from(json["EVENTOS_INVITACION_CONTACTO"].map((x) => ContactArray.fromJson(x))) : [],
    arraycontactoElimimar: json["EVENTOS_INVITACION_CONTACTO_ELIMINAR"] != null ? List<ContactArray>.from(json["EVENTOS_INVITACION_CONTACTO_ELIMINAR"].map((x) => ContactArray.fromJson(x))) : [],
    arrayresponsable: json["EVENTOS_INVITACION_RESPONSABLE"] != null ? List<ResponsableArray>.from(json["EVENTOS_INVITACION_RESPONSABLE"].map((x) => ResponsableArray.fromJson(x))) : [],
    arrayresponsableElimimar: json["EVENTOS_INVITACION_RESPONSABLE_ELIMINAR"] != null ? List<ResponsableArray>.from(json["EVENTOS_INVITACION_RESPONSABLE_ELIMINAR"].map((x) => ResponsableArray.fromJson(x))) : [],
    evntAsunto: json['EVNT_ASUNTO'] ?? '',
    evntComentario: json['EVNT_COMENTARIO'] ?? '',
    evntCoordenadaLatitud: json['EVNT_COORDENADA_LATITUD'] ?? '',
    evntCoordenadaLongitud: json['EVNT_COORDENADA_LONGITUD'] ?? '',
    evntCorreosExternos: json['EVNT_CORREOS_EXTERNOS'] ?? '',
    evntDireccionMapa: json['EVNT_DIRECCION_MAPA'] ?? '',
    evntFechaFinEvento: DateTime.parse(json['EVNT_FECHA_FIN_EVENTO']),
    evntFechaInicioEvento: DateTime.parse(json['EVNT_FECHA_INICIO_EVENTO']),
    evntHoraFinEvento: json['EVNT_HORA_FIN_EVENTO'] ?? '',
    evntHoraInicioEvento: json['EVNT_HORA_INICIO_EVENTO'] ?? '',
    evntHoraRecordatorio: json['EVNT_HORA_RECORDATORIO'] ?? '',
    evntIdEventoIn: json['EVNT_ID_EVENTO_IN'] ?? '',
    evntIdOportunidad: json['EVNT_ID_OPORTUNIDAD'] ?? '',
    evntIdRecordatorio: int.parse(json['EVNT_ID_RECORDATORIO'].toString()),
    evntIdTipoGestion: json['EVNT_ID_TIPO_GESTION'] ?? '',
    evntIdUsuarioRegistro: json['EVNT_ID_USUARIO_REGISTRO'] ?? '',
    evntIdUsuarioResponsable: json['EVNT_ID_USUARIO_RESPONSABLE'] ?? '',
    evntNombreOportunidad: json['EVNT_NOMBRE_OPORTUNIDAD'] ?? '',
    evntNombreTipoGestion: json['EVNT_NOMBRE_TIPO_GESTION'] ?? '',
    evntRuc: json['EVNT_RUC'] ?? '',
    evntUbigeo: json['EVNT_UBIGEO'] ?? '',
    opt: json['OPT'] ?? '',
    todoDia: json['TODO_DIA'] ?? '',
  );

}

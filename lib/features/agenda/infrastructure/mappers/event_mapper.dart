import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/contacts/domain/entities/contact_array.dart';


class EventMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Event(
    id: json['ACTI_ID_ACTIVIDAD'] ?? '',

    arraycontacto: json["ARRAYCONTACTO"] != null ? List<ContactArray>.from(json["ARRAYCONTACTO"].map((x) => ContactArray.fromJson(x))) : [],
    arraycontactoElimimar: json["ARRAYCONTACTO_ELIMIMAR"] != null ? List<ContactArray>.from(json["ARRAYCONTACTO_ELIMIMAR"].map((x) => ContactArray.fromJson(x))) : [],
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
    evntIdRecordatorio: json['EVNT_ID_RECORDATORIO'] ?? '',
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

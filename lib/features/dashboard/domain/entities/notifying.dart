import 'dart:convert';

Notifying notifyingFromJson(String str) => Notifying.fromJson(json.decode(str));

String notifyingToJson(Notifying data) => json.encode(data.toJson());

class Notifying {
  String? accmIdActividadComentario;
  String? accmIdActividad;
  String? accmComentario;
  String? accmLeido;
  String? accmEliminado;
  DateTime? accmFechaRegistro;
  String? accmIdUsuarioRegistro;
  String? userreportName;
  String? userreportAbbrt;
  String? accmTiempoGestion;

  Notifying({
    this.accmIdActividadComentario,
    this.accmIdActividad,
    this.accmComentario,
    this.accmLeido,
    this.accmEliminado,
    this.accmFechaRegistro,
    this.accmIdUsuarioRegistro,
    this.userreportName,
    this.userreportAbbrt,
    this.accmTiempoGestion,
  });

  factory Notifying.fromJson(Map<String, dynamic> json) => Notifying(
        accmIdActividadComentario: json["ACCM_ID_ACTIVIDAD_COMENTARIO"],
        accmIdActividad: json["ACCM_ID_ACTIVIDAD"],
        accmComentario: json["ACCM_COMENTARIO"],
        accmLeido: json["ACCM_LEIDO"],
        accmEliminado: json["ACCM_ELIMINADO"],
        accmFechaRegistro: json["ACCM_FECHA_REGISTRO"] == null
            ? null
            : DateTime.parse(json["ACCM_FECHA_REGISTRO"]),
        accmIdUsuarioRegistro: json["ACCM_ID_USUARIO_REGISTRO"],
        userreportName: json["USERREPORT_NAME"],
        userreportAbbrt: json["USERREPORT_ABBRT"],
        accmTiempoGestion: json["ACCM_TIEMPO_GESTION"],
      );

  Map<String, dynamic> toJson() => {
        "ACCM_ID_ACTIVIDAD_COMENTARIO": accmIdActividadComentario,
        "ACCM_ID_ACTIVIDAD": accmIdActividad,
        "ACCM_COMENTARIO": accmComentario,
        "ACCM_LEIDO": accmLeido,
        "ACCM_ELIMINADO": accmEliminado,
        "ACCM_FECHA_REGISTRO": accmFechaRegistro?.toIso8601String(),
        "ACCM_ID_USUARIO_REGISTRO": accmIdUsuarioRegistro,
        "USERREPORT_NAME": userreportName,
        "USERREPORT_ABBRT": userreportAbbrt,
        "ACCM_TIEMPO_GESTION": accmTiempoGestion,
      };
}

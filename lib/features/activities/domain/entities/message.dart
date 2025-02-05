import 'dart:convert';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  String? accmIdActividadComentario;
  String? accmIdActividad;
  String? accmComentario;
  String? accmLeido;
  String? accmEliminado;
  DateTime? accmFechaRegistro;
  String? accmIdUsuarioRegistro;
  String? userreportName;
  String? userreportAbbrt;
  String? accmEstadoReg;
  String? accmTiempoGestion;

  MessageModel({
    this.accmIdActividadComentario,
    this.accmIdActividad,
    this.accmComentario,
    this.accmLeido,
    this.accmEliminado,
    this.accmFechaRegistro,
    this.accmIdUsuarioRegistro,
    this.userreportName,
    this.userreportAbbrt,
    this.accmEstadoReg,
    this.accmTiempoGestion,
  });

  bool isUserMessage(
    String userID,
  ) =>
      userID == accmIdUsuarioRegistro;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
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
        accmEstadoReg: json["ACCM_ESTADO_REG"],
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
        "ACCM_ESTADO_REG": accmEstadoReg,
        "ACCM_TIEMPO_GESTION": accmTiempoGestion,
      };
}

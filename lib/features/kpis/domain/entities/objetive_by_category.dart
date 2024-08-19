class ObjetiveByCategory {
  String objrIdObjetivo;
  String userreportName;
  String userreportCodigo;
  String userreportAbbrt;
  String actiIdActividad;
  String actiIdUsuarioResponsable;
  String actiNombreResponsable;
  String actiIdTipoGestion;
  DateTime actiFechaActividad;
  String actiHoraActividad;
  String actiRuc;
  String actiRazon;
  String actiIdOportunidad;
  String actiIdContacto;
  String contactoDesc;
  String actiComentario;
  dynamic actiNombreArchivo;
  String actiIdUsuarioRegistro;
  dynamic actiIdUsuarioActualizacion;
  String actiEstadoReg;
  String actiNombreTipoGestion;
  dynamic actiNombreOportunidad;
  String actiTiempoGestion;
  String cchkComentarioCheckIn;
  String cchkComentarioCheckOut;
  String actiIdTipoRegistro;

  ObjetiveByCategory({
    required this.objrIdObjetivo,
    required this.userreportName,
    required this.userreportCodigo,
    required this.userreportAbbrt,
    required this.actiIdActividad,
    required this.actiIdUsuarioResponsable,
    required this.actiNombreResponsable,
    required this.actiIdTipoGestion,
    required this.actiFechaActividad,
    required this.actiHoraActividad,
    required this.actiRuc,
    required this.actiRazon,
    required this.actiIdOportunidad,
    required this.actiIdContacto,
    required this.contactoDesc,
    required this.actiComentario,
    required this.actiNombreArchivo,
    required this.actiIdUsuarioRegistro,
    required this.actiIdUsuarioActualizacion,
    required this.actiEstadoReg,
    required this.actiNombreTipoGestion,
    required this.actiNombreOportunidad,
    required this.actiTiempoGestion,
    required this.cchkComentarioCheckIn,
    required this.cchkComentarioCheckOut,
    required this.actiIdTipoRegistro,
  });

  factory ObjetiveByCategory.fromJson(Map<String, dynamic> json) =>
      ObjetiveByCategory(
        objrIdObjetivo: json["OBJR_ID_OBJETIVO"],
        userreportName: json["USERREPORT_NAME"],
        userreportCodigo: json["USERREPORT_CODIGO"],
        userreportAbbrt: json["USERREPORT_ABBRT"],
        actiIdActividad: json["ACTI_ID_ACTIVIDAD"],
        actiIdUsuarioResponsable: json["ACTI_ID_USUARIO_RESPONSABLE"],
        actiNombreResponsable: json["ACTI_NOMBRE_RESPONSABLE"],
        actiIdTipoGestion: json["ACTI_ID_TIPO_GESTION"],
        actiFechaActividad: DateTime.parse(json["ACTI_FECHA_ACTIVIDAD"]),
        actiHoraActividad: json["ACTI_HORA_ACTIVIDAD"],
        actiRuc: json["ACTI_RUC"],
        actiRazon: json["ACTI_RAZON"],
        actiIdOportunidad: json["ACTI_ID_OPORTUNIDAD"],
        actiIdContacto: json["ACTI_ID_CONTACTO"],
        contactoDesc: json["CONTACTO_DESC"],
        actiComentario: json["ACTI_COMENTARIO"],
        actiNombreArchivo: json["ACTI_NOMBRE_ARCHIVO"],
        actiIdUsuarioRegistro: json["ACTI_ID_USUARIO_REGISTRO"],
        actiIdUsuarioActualizacion: json["ACTI_ID_USUARIO_ACTUALIZACION"],
        actiEstadoReg: json["ACTI_ESTADO_REG"],
        actiNombreTipoGestion: json["ACTI_NOMBRE_TIPO_GESTION"],
        actiNombreOportunidad: json["ACTI_NOMBRE_OPORTUNIDAD"],
        actiTiempoGestion: json["ACTI_TIEMPO_GESTION"],
        cchkComentarioCheckIn: json["CCHK_COMENTARIO_CHECK_IN"],
        cchkComentarioCheckOut: json["CCHK_COMENTARIO_CHECK_OUT"],
        actiIdTipoRegistro: json["ACTI_ID_TIPO_REGISTRO"],
      );

  Map<String, dynamic> toJson() => {
        "OBJR_ID_OBJETIVO": objrIdObjetivo,
        "USERREPORT_NAME": userreportName,
        "USERREPORT_CODIGO": userreportCodigo,
        "USERREPORT_ABBRT": userreportAbbrt,
        "ACTI_ID_ACTIVIDAD": actiIdActividad,
        "ACTI_ID_USUARIO_RESPONSABLE": actiIdUsuarioResponsable,
        "ACTI_NOMBRE_RESPONSABLE": actiNombreResponsable,
        "ACTI_ID_TIPO_GESTION": actiIdTipoGestion,
        "ACTI_FECHA_ACTIVIDAD":
            "${actiFechaActividad.year.toString().padLeft(4, '0')}-${actiFechaActividad.month.toString().padLeft(2, '0')}-${actiFechaActividad.day.toString().padLeft(2, '0')}",
        "ACTI_HORA_ACTIVIDAD": actiHoraActividad,
        "ACTI_RUC": actiRuc,
        "ACTI_RAZON": actiRazon,
        "ACTI_ID_OPORTUNIDAD": actiIdOportunidad,
        "ACTI_ID_CONTACTO": actiIdContacto,
        "CONTACTO_DESC": contactoDesc,
        "ACTI_COMENTARIO": actiComentario,
        "ACTI_NOMBRE_ARCHIVO": actiNombreArchivo,
        "ACTI_ID_USUARIO_REGISTRO": actiIdUsuarioRegistro,
        "ACTI_ID_USUARIO_ACTUALIZACION": actiIdUsuarioActualizacion,
        "ACTI_ESTADO_REG": actiEstadoReg,
        "ACTI_NOMBRE_TIPO_GESTION": actiNombreTipoGestion,
        "ACTI_NOMBRE_OPORTUNIDAD": actiNombreOportunidad,
        "ACTI_TIEMPO_GESTION": actiTiempoGestion,
        "CCHK_COMENTARIO_CHECK_IN": cchkComentarioCheckIn,
        "CCHK_COMENTARIO_CHECK_OUT": cchkComentarioCheckOut,
        "ACTI_ID_TIPO_REGISTRO": actiIdTipoRegistro,
      };
}

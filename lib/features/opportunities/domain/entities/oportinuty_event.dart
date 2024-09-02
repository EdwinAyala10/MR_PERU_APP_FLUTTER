class OportunityEvent {
  String? evntIdEvento;
  String? evntAsunto;
  DateTime? evntFechaInicioEvento;
  DateTime? evntFechaFinEvento;
  String? evntHoraInicioEvento;
  String? evntHoraFinEvento;
  String? evntIdRecordatorio;
  String? evntDiaCompleto;
  String? evntIdUsuarioResponsable;
  String? evntIdTipoGestion;
  String? evntIdTipoRegistro;
  String? evntRuc;
  String? razon;
  String? razonComercial;
  String? evntIdOportunidad;
  String? evntComentario;
  String? evntUbigeo;
  String? evntCoordenadaLatitud;
  String? evntCoordenadaLongitud;
  String? evntDireccionMapa;
  DateTime? evntFechaRegistro;
  dynamic evntFechaActualizacion;
  String? evntIdUsuarioRegistro;
  dynamic evntIdUsuarioActualizacion;
  String? evntEstadoReg;
  String? evntNombreTipoGestion;
  String? evntNombreOportunidad;

  OportunityEvent({
    this.evntIdEvento,
    this.evntAsunto,
    this.evntFechaInicioEvento,
    this.evntFechaFinEvento,
    this.evntHoraInicioEvento,
    this.evntHoraFinEvento,
    this.evntIdRecordatorio,
    this.evntDiaCompleto,
    this.evntIdUsuarioResponsable,
    this.evntIdTipoGestion,
    this.evntIdTipoRegistro,
    this.evntRuc,
    this.razon,
    this.razonComercial,
    this.evntIdOportunidad,
    this.evntComentario,
    this.evntUbigeo,
    this.evntCoordenadaLatitud,
    this.evntCoordenadaLongitud,
    this.evntDireccionMapa,
    this.evntFechaRegistro,
    this.evntFechaActualizacion,
    this.evntIdUsuarioRegistro,
    this.evntIdUsuarioActualizacion,
    this.evntEstadoReg,
    this.evntNombreTipoGestion,
    this.evntNombreOportunidad,
  });

  factory OportunityEvent.fromJson(Map<String, dynamic> json) =>
      OportunityEvent(
        evntIdEvento: json["EVNT_ID_EVENTO"],
        evntAsunto: json["EVNT_ASUNTO"],
        evntFechaInicioEvento: json["EVNT_FECHA_INICIO_EVENTO"] == null
            ? null
            : DateTime.parse(json["EVNT_FECHA_INICIO_EVENTO"]),
        evntFechaFinEvento: json["EVNT_FECHA_FIN_EVENTO"] == null
            ? null
            : DateTime.parse(json["EVNT_FECHA_FIN_EVENTO"]),
        evntHoraInicioEvento: json["EVNT_HORA_INICIO_EVENTO"],
        evntHoraFinEvento: json["EVNT_HORA_FIN_EVENTO"],
        evntIdRecordatorio: json["EVNT_ID_RECORDATORIO"],
        evntDiaCompleto: json["EVNT_DIA_COMPLETO"],
        evntIdUsuarioResponsable: json["EVNT_ID_USUARIO_RESPONSABLE"],
        evntIdTipoGestion: json["EVNT_ID_TIPO_GESTION"],
        evntIdTipoRegistro: json["EVNT_ID_TIPO_REGISTRO"],
        evntRuc: json["EVNT_RUC"],
        razon: json["RAZON"],
        razonComercial: json["RAZON_COMERCIAL"],
        evntIdOportunidad: json["EVNT_ID_OPORTUNIDAD"],
        evntComentario: json["EVNT_COMENTARIO"],
        evntUbigeo: json["EVNT_UBIGEO"],
        evntCoordenadaLatitud: json["EVNT_COORDENADA_LATITUD"],
        evntCoordenadaLongitud: json["EVNT_COORDENADA_LONGITUD"],
        evntDireccionMapa: json["EVNT_DIRECCION_MAPA"],
        evntFechaRegistro: json["EVNT_FECHA_REGISTRO"] == null
            ? null
            : DateTime.parse(json["EVNT_FECHA_REGISTRO"]),
        evntFechaActualizacion: json["EVNT_FECHA_ACTUALIZACION"],
        evntIdUsuarioRegistro: json["EVNT_ID_USUARIO_REGISTRO"],
        evntIdUsuarioActualizacion: json["EVNT_ID_USUARIO_ACTUALIZACION"],
        evntEstadoReg: json["EVNT_ESTADO_REG"],
        evntNombreTipoGestion: json["EVNT_NOMBRE_TIPO_GESTION"],
        evntNombreOportunidad: json["EVNT_NOMBRE_OPORTUNIDAD"],
      );

  Map<String, dynamic> toJson() => {
        "EVNT_ID_EVENTO": evntIdEvento,
        "EVNT_ASUNTO": evntAsunto,
        "EVNT_FECHA_INICIO_EVENTO":
            "${evntFechaInicioEvento!.year.toString().padLeft(4, '0')}-${evntFechaInicioEvento!.month.toString().padLeft(2, '0')}-${evntFechaInicioEvento!.day.toString().padLeft(2, '0')}",
        "EVNT_FECHA_FIN_EVENTO":
            "${evntFechaFinEvento!.year.toString().padLeft(4, '0')}-${evntFechaFinEvento!.month.toString().padLeft(2, '0')}-${evntFechaFinEvento!.day.toString().padLeft(2, '0')}",
        "EVNT_HORA_INICIO_EVENTO": evntHoraInicioEvento,
        "EVNT_HORA_FIN_EVENTO": evntHoraFinEvento,
        "EVNT_ID_RECORDATORIO": evntIdRecordatorio,
        "EVNT_DIA_COMPLETO": evntDiaCompleto,
        "EVNT_ID_USUARIO_RESPONSABLE": evntIdUsuarioResponsable,
        "EVNT_ID_TIPO_GESTION": evntIdTipoGestion,
        "EVNT_ID_TIPO_REGISTRO": evntIdTipoRegistro,
        "EVNT_RUC": evntRuc,
        "RAZON": razon,
        "RAZON_COMERCIAL": razonComercial,
        "EVNT_ID_OPORTUNIDAD": evntIdOportunidad,
        "EVNT_COMENTARIO": evntComentario,
        "EVNT_UBIGEO": evntUbigeo,
        "EVNT_COORDENADA_LATITUD": evntCoordenadaLatitud,
        "EVNT_COORDENADA_LONGITUD": evntCoordenadaLongitud,
        "EVNT_DIRECCION_MAPA": evntDireccionMapa,
        "EVNT_FECHA_REGISTRO": evntFechaRegistro?.toIso8601String(),
        "EVNT_FECHA_ACTUALIZACION": evntFechaActualizacion,
        "EVNT_ID_USUARIO_REGISTRO": evntIdUsuarioRegistro,
        "EVNT_ID_USUARIO_ACTUALIZACION": evntIdUsuarioActualizacion,
        "EVNT_ESTADO_REG": evntEstadoReg,
        "EVNT_NOMBRE_TIPO_GESTION": evntNombreTipoGestion,
        "EVNT_NOMBRE_OPORTUNIDAD": evntNombreOportunidad,
      };
}

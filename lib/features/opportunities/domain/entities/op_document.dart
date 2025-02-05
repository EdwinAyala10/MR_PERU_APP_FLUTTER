class OpDocument {
  String oadjIdOportunidadAdjunto;
  String oadjIdOportunidad;
  String oadjIdTipoAdjunto;
  String oadjNombreArchivo;
  String oadjTipoArchivo;
  String oadjNombreOriginal;
  String oadjRutalRelativa;
  String oadjEstado;
  String oadjEnlace;

  OpDocument({
    required this.oadjIdOportunidadAdjunto,
    required this.oadjIdOportunidad,
    required this.oadjIdTipoAdjunto,
    required this.oadjNombreArchivo,
    required this.oadjTipoArchivo,
    required this.oadjNombreOriginal,
    required this.oadjRutalRelativa,
    required this.oadjEstado,
    required this.oadjEnlace,
  });

  factory OpDocument.fromJson(Map<String, dynamic> json) => OpDocument(
        oadjIdOportunidadAdjunto: json["OADJ_ID_OPORTUNIDAD_ADJUNTO"],
        oadjIdOportunidad: json["OADJ_ID_OPORTUNIDAD"],
        oadjIdTipoAdjunto: json["OADJ_ID_TIPO_ADJUNTO"],
        oadjNombreArchivo: json["OADJ_NOMBRE_ARCHIVO"],
        oadjTipoArchivo: json["OADJ_TIPO_ARCHIVO"],
        oadjNombreOriginal: json["OADJ_NOMBRE_ORIGINAL"],
        oadjRutalRelativa: json["OADJ_RUTAL_RELATIVA"],
        oadjEstado: json["OADJ_ESTADO"].toString(),
        oadjEnlace: json["OADJ_ENLACE"],
      );

  Map<String, dynamic> toJson() => {
        "OADJ_ID_OPORTUNIDAD_ADJUNTO": oadjIdOportunidadAdjunto,
        "OADJ_ID_OPORTUNIDAD": oadjIdOportunidad,
        "OADJ_ID_TIPO_ADJUNTO": oadjIdTipoAdjunto,
        "OADJ_NOMBRE_ARCHIVO": oadjNombreArchivo,
        "OADJ_TIPO_ARCHIVO": oadjTipoArchivo,
        "OADJ_NOMBRE_ORIGINAL": oadjNombreOriginal,
        "OADJ_RUTAL_RELATIVA": oadjRutalRelativa,
        "OADJ_ESTADO": oadjEstado,
        "OADJ_ENLACE": oadjEnlace,
      };
}

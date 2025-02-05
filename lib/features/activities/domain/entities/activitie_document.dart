class ACDocument {
  String oadjIdOportunidadAdjunto;
  String oadjIdOportunidad;
  String oadjIdTipoAdjunto;
  String oadjNombreArchivo;
  String oadjTipoArchivo;
  String oadjNombreOriginal;
  String oadjRutalRelativa;
  String oadjEstado;
  String oadjEnlace;

  ACDocument({
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

  factory ACDocument.fromJson(Map<String, dynamic> json) => ACDocument(
        oadjIdOportunidadAdjunto: json["ACDJ_ID_ACTIVIDAD_ADJUNTO"],
        oadjIdOportunidad: json["ACDJ_ID_ACTIVIDAD"],
        oadjIdTipoAdjunto: json["ACDJ_ID_TIPO_ADJUNTO"],
        oadjNombreArchivo: json["ACDJ_NOMBRE_ARCHIVO"],
        oadjTipoArchivo: json["ACDJ_TIPO_ARCHIVO"],
        oadjNombreOriginal: json["ACDJ_NOMBRE_ORIGINAL"],
        oadjRutalRelativa: json["ACDJ_RUTAL_RELATIVA"],
        oadjEstado: json["ACDJ_ESTADO"].toString(),
        oadjEnlace: json["ACDJ_ENLACE"],
      );

  Map<String, dynamic> toJson() => {
        "ACDJ_ID_ACTIVIDAD_ADJUNTO": oadjIdOportunidadAdjunto,
        "ACDJ_ID_ACTIVIDAD": oadjIdOportunidad,
        "ACDJ_ID_TIPO_ADJUNTO": oadjIdTipoAdjunto,
        "ACDJ_NOMBRE_ARCHIVO": oadjNombreArchivo,
        "ACDJ_TIPO_ARCHIVO": oadjTipoArchivo,
        "ACDJ_NOMBRE_ORIGINAL": oadjNombreOriginal,
        "ACDJ_RUTAL_RELATIVA": oadjRutalRelativa,
        "ACDJ_ESTADO": oadjEstado,
        "ACDJ_ENLACE": oadjEnlace,
      };
}

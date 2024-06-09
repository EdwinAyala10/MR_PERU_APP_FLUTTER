import '../../domain/domain.dart';


class DocumentMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Document(
    adjtIdAdjunto: json['ADJT_ID_ADJUNTO'] ?? '',
    adjtTipoRegistro: json['ADJT_TIPO_REGISTRO'] ?? '',
    adjtNombreArchivo: json['ADJT_NOMBRE_ARCHIVO'] ?? '',
    adjtTipoArchivo: json['ADJT_TIPO_ARCHIVO'] ?? '',
    adjtNombreOriginal: json['ADJT_NOMBRE_ORIGINAL'] ?? '',
    adjtRutalRelativa: json['ADJT_RUTAL_RELATIVA'] ?? '',
    adjtEnlace: json['ADJT_ENLACE'] ?? '',
    adjtIdTipoRegistro: json['ADJT_ID_TIPO_REGISTRO'] ?? '',
    adjtEstado: json['ADJT_ESTADO'].toString(),
  );

}

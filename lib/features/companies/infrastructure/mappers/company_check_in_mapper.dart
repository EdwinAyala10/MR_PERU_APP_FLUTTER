import 'package:crm_app/features/companies/domain/domain.dart';


class CompanyCheckInMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CompanyCheckIn(
    cchkIdClientesCheck: json['CCHK_ID_CLIENTES_CHECK'] ?? '',
    cchkRuc: json['CCHK_RUC'] ?? '',
    cchkIdOportunidad: json['CCHK_ID_OPORTUNIDAD'] ?? '',
    cchkIdContacto: json['CCHK_ID_CONTACTO'] ?? '',
    cchkIdEstadoCheck: json['CCHK_ID_ESTADO_CHECK'] ?? '',
    cchkIdComentario:  json['CCHK_ID_COMENTARIO'] ?? '',
    cchkIdUsuarioResponsable:  json['CCHK_ID_USUARIO_RESPONSABLE'] ?? '',
    cchkUbigeo:  json['CCHK_UBIGEO'] ?? '',
    cchkCoordenadaLatitud:  json['CCHK_COORDENADA_LATITUD'] ?? '',
    cchkCoordenadaLongitud:  json['CCHK_COORDENADA_LONGITUD'] ?? '',
    cchkDireccionMapa:  json['CCHK_DIRECCION_MAPA'] ?? '',
    cchkIdUsuarioRegistro:  json['CCHK_ID_USUARIO_REGISTRO'] ?? '',
    cchkNombreContacto:  json['CCHK_NOMBRE_CONTACTO'] ?? '',
    cchkNombreOportunidad:  json['CCHK_NOMBRE_OPORTUNIDAD'] ?? '',
    cchkLocalCodigo:  json['CCHK_LOCAL_CODIGO'] ?? '',
    cchkLocalNombre:  json['CCHK_LOCAL_NOMBRE'] ?? '',
  );

}

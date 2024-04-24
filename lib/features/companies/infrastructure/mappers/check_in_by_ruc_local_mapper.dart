import 'package:crm_app/features/companies/domain/entities/check_in_by_ruc_local.dart';


class CheckInByRucLocalMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CheckInByRucLocal(
    cchkIdClientesCheck: json['CCHK_ID_CLIENTES_CHECK'] ?? '',
    ruc: json['RUC'] ?? '',
    cchkLocalCodigo: json['LOCAL_CODIGO'] ?? '',
    localNombre: json['LOCAL_NOMBRE'] ?? '',
    idOportunidad: json['ID_OPORTUNIDAD'] ?? '',
    oprtNombre:  json['OPRT_NOMBRE'] ?? '',
    idContacto:  json['ID_CONTACTO'] ?? '',
    contactoDesc:  json['CONTACTO_DESC'] ?? '',
    cchkIdEstadoCheck:  json['CCHK_ID_ESTADO_CHECK'] ?? '',
    cchkIdUsuarioResponsable:  json['CCHK_ID_USUARIO_RESPONSABLE'] ?? '',
    cchkIdActividad:  json['CCHK_ID_ACTIVIDAD'] ?? '',
    coordenadasGeo:  json['COORDENADAS_GEO'] ?? '',
    coordenadasLatitud:  json['COORDENADAS_LATITUD'] ?? '',
    coordenadasLongitud:  json['COORDENADAS_LONGITUD'] ?? '',
    razon:  json['RAZON'] ?? '', 
    localDireccion:  json['LOCAL_DIRECCION'] ?? '', 
  );

}
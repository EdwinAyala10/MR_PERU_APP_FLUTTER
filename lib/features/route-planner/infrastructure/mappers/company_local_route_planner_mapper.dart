import '../../domain/domain.dart';
import '../../../companies/domain/entities/company_check_in_ultima_visita.dart';

class CompanyLocalRoutePlannerMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) {
    // Parsear CCHK_ULTIMA_VISITA (formato: array de objetos)
    List<CompanyCheckInUltimaVisita>? cchkUltimaVisita;
    if (json['CCHK_ULTIMA_VISITA'] != null) {
      try {
        final ultimaVisitaList = json['CCHK_ULTIMA_VISITA'] as List;
        cchkUltimaVisita = ultimaVisitaList
            .map((item) => CompanyCheckInUltimaVisita(
                  cchkLocalCodigoIn: item['CCHK_LOCAL_CODIGO_IN'] != null
                      ? int.tryParse(item['CCHK_LOCAL_CODIGO_IN'].toString())
                      : null,
                  cchkComentarioCheckIn: item['CCHK_COMENTARIO_CHECK_IN'] ?? '',
                  cchkComentarioCheckOut:
                      item['CCHK_COMENTARIO_CHECK_OUT'] ?? '',
                  cchkFechaRegistroCheckIn:
                      item['CCHK_FECHA_REGISTRO_CHECK_IN'] ?? '',
                ))
            .toList();
      } catch (e) {
        cchkUltimaVisita = null;
      }
    }

    return CompanyLocalRoutePlanner(
      id: json['LOCAL_CODIGO'] ?? '',
      ruc: json['RUC'] ?? '',
      localCodigo: json['LOCAL_CODIGO'] ?? '',
      localNombre: json['LOCAL_NOMBRE'] ?? '',
      razon: json['RAZON'] ?? '',
      razonComercial: json['RAZON_COMERCIAL'] ?? '',
      direccion: json['DIRECCION'] ?? '',
      telefono: json['TELEFONO'] ?? '',
      email: json['EMAIL'] ?? '',
      tipocliente: json['TIPOCLIENTE'] ?? '',
      observaciones: json['OBSERVACIONES'] ?? '',
      estado: json['ESTADO'] ?? '',
      calificacion: json['CALIFICACION'] ?? '',
      visibleTodos: json['VISIBLE_TODOS'] ?? '',
      codigoPostal: json['CODIGO_POSTAL'] ?? '',
      idUsuarioRegistro: json['ID_USUARIO_REGISTRO'] ?? '',
      clienteNombreEstado: json['CLIENTE_NOMBRE_ESTADO'] ?? '',
      clienteNombreTipo: json['CLIENTE_NOMBRE_TIPO'] ?? '',
      userreportName1: json['USERREPORT_NAME_1'] ?? '',
      userreportName: json['USERREPORT_NAME'] ?? '',
      localDireccion: json['LOCAL_DIRECCION'] ?? '',
      localCantidad: json['LOCAL_CANTIDAD'] ?? '',
      localDistrito: json['LOCAL_DISTRITO'] ?? '',
      localCoordenadasGeo: json['LOCAL_COORDENADAS_GEO'] ?? '',
      localCoordenadasLatitud: json['LOCAL_COORDENADAS_LATITUD'] ?? '',
      localCoordenadasLongitud: json['LOCAL_COORDENADAS_LONGITUD'] ?? '',
      localUbigeoCodigo: json['LOCAL_UBIGEO_CODIGO'] ?? '',
      localCodigoPostal: json['LOCAL_CODIGO_POSTAL'] ?? '',
      cchkFechaRegistroCheckIn: json['CCHK_FECHA_REGISTRO_CHECK_IN'] ?? '',
      cchkUltimaVisita: cchkUltimaVisita,
    );
  }
}

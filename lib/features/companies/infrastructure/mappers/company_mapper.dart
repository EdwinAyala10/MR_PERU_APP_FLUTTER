import '../../domain/domain.dart';
import '../../../kpis/domain/entities/array_user.dart';

class CompanyMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) {
    // Parsear LOCAL_COORDENADAS (formato: array de objetos con "LOCAL_COORDENADAS": "lng,lat")
    List<String>? localCoordenadas;
    if (json['LOCAL_COORDENADAS'] != null) {
      try {
        final coordenadasList = json['LOCAL_COORDENADAS'] as List;
        localCoordenadas = coordenadasList
            .map((item) => (item['LOCAL_COORDENADAS'] as String?)?.trim() ?? '')
            .where((coord) => coord.isNotEmpty)
            .toList();
      } catch (e) {
        localCoordenadas = null;
      }
    }

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

    return Company(
      rucId: json['RUC'] ?? '',
      ruc: json['RUC'] ?? '',
      razon: json['RAZON'] ?? '',
      direccion: json['DIRECCION'] ?? '',
      telefono: json['TELEFONO'] ?? '',
      email: json['EMAIL'] ?? '',
      tipocliente: json['TIPOCLIENTE'] ?? '',
      observaciones: json['OBSERVACIONES'] ?? '',
      nombreRubro: json['NOMBRE_RUBRO'] ?? '',
      idRubro: json['ID_RUBRO'] ?? '',
      fechaActualizacion: json['FECHA_ACTUALIZACION'] == Null
          ? DateTime.parse(json['FECHA_ACTUALIZACION'])
          : null,
      usuarioActualizacion: json['USUARIO_ACTUALIZACION'] ?? '',
      estado: json['ESTADO'] ?? '',
      estadoCliente: json['ESTADO_CLIENTE'] ?? '',
      localNombre: json['LOCAL_NOMBRE'] ?? '',
      departamento: json['DEPARTAMENTO'] ?? '',
      provincia: json['PROVINCIA'] ?? '',
      distrito: json['DISTRITO'] ?? '',
      clienteCoordenadasGeo: json['CLIENTE_COORDENADAS_GEO'] ?? '',
      clienteCoordenadasLatitud: json['CLIENTE_COORDENADAS_LONGITUD'] ?? '',
      clienteCoordenadasLongitud: json['CLIENTE_COORDENADAS_LATITUD'] ?? '',
      seguimientoComentario: json['SEGUIMIENTO_COMENTARIO'] ?? '',
      website: json['WEBSITE'] ?? '',
      cchkIdEstadoCheck: json['CCHK_ID_ESTADO_CHECK'],
      calificacion: json['CALIFICACION'] ?? '',
      nombreCalificacion: json['NOMBRE_CALIFICACION'] ?? '',
      visibleTodos: json['VISIBLE_TODOS'] ?? '',
      codigoPostal: json['CODIGO_POSTAL'] ?? '',
      clienteNombreEstado: json['CLIENTE_NOMBRE_ESTADO'] ?? '',
      idUsuarioRegistro: json['ID_USUARIO_REGISTRO'] ?? '',
      usuarioRegistro: json['USUARIO_REGISTRO'] ?? '',
      clienteNombreTipo: json['CLIENTE_NOMBRE_TIPO'] ?? '',
      localCodigoPostal: json['LOCAL_CODIGO_POSTAL'] ?? '',
      localDireccion: json['LOCAL_DIRECCION'] ?? '',
      localDistrito: json['LOCAL_DISTRITO'] ?? '',
      localCantidad: json['LOCAL_CANTIDAD'] ?? '',
      userreporteName: json['USERREPORT_NAME'] ?? '',
      razonComercial: json['RAZON_COMERCIAL'] ?? '',
      localCoordenadas: localCoordenadas,
      actiComentario: json['ACTI_COMENTARIO'] ?? '',
      cchkUltimaVisita: cchkUltimaVisita,
      arrayresponsables: json["CLIENTES_RESPONSABLE"] != null
          ? List<ArrayUser>.from(
              json["CLIENTES_RESPONSABLE"].map((x) => ArrayUser.fromJson(x)))
          : [],
    );
  }
}

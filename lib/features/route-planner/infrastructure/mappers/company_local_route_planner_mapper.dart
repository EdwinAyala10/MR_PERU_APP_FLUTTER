import '../../domain/domain.dart';


class CompanyLocalRoutePlannerMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CompanyLocalRoutePlanner(
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
  );

}

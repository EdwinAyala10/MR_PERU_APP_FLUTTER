import '../../domain/domain.dart';
import '../../../kpis/domain/entities/array_user.dart';


class CompanyMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Company(
    rucId: json['RUC'] ?? '',
    ruc: json['RUC'],
    razon:  json['RAZON'],
    direccion: json['DIRECCION'] ?? '',
    telefono: json['TELEFONO'] ?? '',
    email: json['EMAIL'] ?? '',
    tipocliente: json['TIPOCLIENTE'] ?? '',
    observaciones: json['OBSERVACIONES'] ?? '',
    nombreRubro: json['NOMBRE_RUBRO'] ?? '',
    idRubro: json['ID_RUBRO'] ?? '',
    fechaActualizacion: json['FECHA_ACTUALIZACION'] == Null ? DateTime.parse(json['FECHA_ACTUALIZACION']) : null,
    usuarioActualizacion: json['USUARIO_ACTUALIZACION'] ?? '',
    estado: json['ESTADO'] ?? '',
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
    arrayresponsables: json["CLIENTES_RESPONSABLE"] != null ? List<ArrayUser>.from(json["CLIENTES_RESPONSABLE"].map((x) => ArrayUser.fromJson(x))) : [],
  );

}

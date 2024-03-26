import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/entities/array_user.dart';


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
    fechaActualizacion: json['FECHA_ACTUALIZACION'] == Null ? DateTime.parse(json['FECHA_ACTUALIZACION']) : null,
    usuarioActualizacion: json['USUARIO_ACTUALIZACION'] ?? '',
    estado: json['ESTADO'] ?? '',
    localNombre: json['LOCAL_NOMBRE'] ?? '',
    departamento: json['DEPARTAMENTO'] ?? '',
    provincia: json['PROVINCIA'] ?? '',
    distrito: json['DISTRITO'] ?? '',
    seguimientoComentario: json['SEGUIMIENTO_COMENTARIO'] ?? '',
    website: json['WEBSITE'] ?? '',
    cchkIdEstadoCheck: json['CCHK_ID_ESTADO_CHECK'],
    calificacion: json['CALIFICACION'] ?? '',
    visibleTodos: json['VISIBLE_TODOS'] ?? '',
    codigoPostal: json['CODIGO_POSTAL'] ?? '',
    idUsuarioRegistro: json['ID_USUARIO_REGISTRO'] ?? '',
    usuarioRegistro: json['USUARIO_REGISTRO'] ?? '',
    arrayresponsables: json["CLIENTES_RESPONSABLE"] != null ? List<ArrayUser>.from(json["CLIENTES_RESPONSABLE"].map((x) => ArrayUser.fromJson(x))) : [],
  );

}

import 'package:crm_app/features/companies/domain/domain.dart';

class CompanyGetMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Company(
    ruc: json['RUC'],
    razon:  json['RAZON'],
    direccion: json['DIRECCION'],
    telefono: json['TELEFONO'],
    email: json['EMAIL'],
    tipocliente: json['TIPOCLIENTE'],
    observaciones: json['OBSERVACIONES'],
    fechaActualizacion: DateTime.parse(json['FECHA_ACTUALIZACION']),
    usuarioActualizacion: json['USUARIO_ACTUALIZACION'],
    estado: json['ESTADO'],
    departamento: json['DEPARTAMENTO'],
    provincia: json['PROVINCIA'],
    distrito: json['DISTRITO'],
    seguimientoComentario: json['SEGUIMIENTO_COMENTARIO'],
    website: json['WEBSITE'],
    calificacion: json['CALIFICACION'],
    visibleTodos: json['VISIBLE_TODOS'],
    codigoPostal: json['CODIGO_POSTAL'],
    usuarioRegistro: json['USUARIO_REGISTRO'],
  );

}

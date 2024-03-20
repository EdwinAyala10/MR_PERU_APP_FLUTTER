import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
import 'package:crm_app/features/kpis/domain/entities/periodicidad.dart';


class KpiMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Kpi(
    id: json['OBJR_ID_OBJETIVO'] ?? '',
    objrNombre: json['OBJR_NOMBRE'] ?? '',
    objrIdUsuarioResponsable: json['OBJR_ID_USUARIO_RESPONSABLE'] ?? '',
    objrIdAsignacion: json["OBJR_ID_ASIGNACION"] ?? '',
    objrIdTipo: json['OBJR_ID_TIPO'] ?? '',
    objrIdPeriodicidad: json['OBJR_ID_PERIODICIDAD'] ?? '',
    objrObservaciones: json['OBJR_OBSERVACIONES'] ?? '',
    objrIdUsuarioRegistro: json['OBJR_ID_USUARIO_REGISTRO'] ?? '',
    objrIdCategoria: json['OBJR_ID_CATEGORIA'] ?? '',

    objrNombreAsignacion: json['OBJR_NOMNRE_ASIGNACION'] ?? '',
    objrNombreCategoria: json['OBJR_NOMBRE_CATEGORIA'] ?? '',
    objrNombreTipo: json['OBJR_NOMNRE_TIPO'] ?? '',
    objrNombrePeriodicidad: json['OBJR_NOMNRE_PERIODICIDAD'] ?? '',
    totalRegistro: json['TOTAL_REGISTRO'] ?? 0,
    porcentaje: (json['PORCENTAJE']?? 0.00).toDouble() ,
    objrCantidad: json['OBJR_CANTIDAD'] ?? '0',
    usuariosAsignados: json["USUARIOS_ASIGNADOS"] != null ? List<UsuarioAsignado>.from(json["USUARIOS_ASIGNADOS"].map((x) => UsuarioAsignado.fromJson(x))) : [],
    arrayuserasignacion: json["ARRAYUSERASIGNACION"] != null ? List<ArrayUser>.from(json["ARRAYUSERASIGNACION"].map((x) => ArrayUser.fromJson(x))) : [],
    peobIdPeriodicidad: json["PEOB_ID_PERIODICIDAD"] != null ? List<Periodicidad>.from(json["PEOB_ID_PERIODICIDAD"].map((x) => Periodicidad.fromJson(x))) : [],
  );

}

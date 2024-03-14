import 'package:crm_app/features/kpis/domain/domain.dart';


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
    objrNombreCategoria: json['OBJR_NOMNRE_CATEGORIA'] ?? '',
    objrNombreTipo: json['OBJR_NOMNRE_TIPO'] ?? '',
    objrNombrePeriodicidad: json['OBJR_NOMNRE_PERIODICIDAD'] ?? '',

  );

}

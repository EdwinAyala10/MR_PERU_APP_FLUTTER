import '../../domain/entities/status_opportunity.dart';

class StatusOpportunityMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => StatusOpportunity(
    recdNombre: json['RECD_NOMBRE'] ?? '',
    totalPorcentaje: json['TOTAL_PORCENTAJE'] ?? '',
    cantidadOportunidad: json['CANTIDAD_OPORTUNIDAD'] ?? '',
    totalOportunidad: json['TOTAL_OPORTUNIDAD'] ?? '',
    totalPonderado: json['TOTA_PONDERADO'] ?? '',
  );

}

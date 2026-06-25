import '../../domain/entities/kpi_stats.dart';

class KpiStatsMapper {
  static KpiStats jsonToEntity(Map<String, dynamic> json) {
    return KpiStats(
      periValorPeriodo: json['PERI_VALOR_PERIODO'] ?? '',
      periCodigo: json['PERI_CODIGO'] ?? '',
      periNombreMes: json['PERI_NOMBRE_MES'] ?? '',
      periNombreMesAbr: json['PERI_NOMBRE_MES_ABR'] ?? '',
      objrCantidad:
          double.tryParse(json['OBJR_CANTIDAD']?.toString() ?? '0') ?? 0,
      objrIdPeriodicidad: json['OBJR_ID_PERIODICIDAD'] ?? '',
      objrNombrePeriodicidad: json['OBJR_NOMBRE_PERIODICIDAD'] ?? '',
      userReportName: json['USERREPORT_NAME'] ?? '',
      userReportCodigo: json['USERREPORT_CODIGO'] ?? '',
      totalRegistro:
          double.tryParse(json['TOTAL_REGISTRO']?.toString() ?? '0') ?? 0,
      avance: double.tryParse(json['AVANCE']?.toString() ?? '0') ?? 0,
      avanceTextColor: json['AVANCE_TEXT_COLOR'] ?? '#FFFFFF',
    );
  }

  static List<KpiStats> jsonToListEntity(List<dynamic> jsonList) {
    return jsonList
        .map((item) => jsonToEntity(item as Map<String, dynamic>))
        .toList();
  }
}

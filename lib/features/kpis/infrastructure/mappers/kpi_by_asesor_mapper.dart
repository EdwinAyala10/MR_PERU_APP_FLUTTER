import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/infrastructure/mappers/kpi_mapper.dart';

class KpiByAsesorMapper {
  static List<KpisByAsesor> jsonToListEntity(Map<String, dynamic> json) {
    final List<KpisByAsesor> list = [];

    if (json['data'] != null) {
      for (var userReport in json['data']) {
        List<Kpi> semanal = [];
        List<Kpi> mensual = [];
        List<Kpi> anual = [];

        if (userReport['PERIODICIDAD'] != null) {
          for (var periodicity in userReport['PERIODICIDAD']) {
            List<Kpi> objectives = [];
            if (periodicity['OBJETIVO'] != null) {
              for (var objective in periodicity['OBJETIVO']) {
                try {
                  objectives.add(KpiMapper.jsonToEntity(objective));
                } catch (e) {
                  print('Error mapping KPI objective: $e');
                }
              }
            }

            final periodicidadId = periodicity['OBJR_ID_PERIODICIDAD'];
            if (periodicidadId == '01') {
              semanal = objectives;
            } else if (periodicidadId == '02') {
              mensual = objectives;
            } else if (periodicidadId == '04') {
              anual = objectives;
            }
          }
        }

        list.add(KpisByAsesor(
          asesorNombre: userReport['USERREPORT_NAME'] ?? '',
          asesorCodigo: userReport['USERREPORT_CODIGO'] ?? '',
          asesorAbbrt: userReport['USERREPORT_ABBRT'] ?? '',
          totalRegistro: (userReport['TOTAL_REGISTRO'] ?? 0).toDouble(),
          porcentaje: (userReport['PORCENTAJE'] ?? 0).toDouble(),
          semanal: semanal,
          mensual: mensual,
          anual: anual,
        ));
      }
    }

    return list;
  }
}

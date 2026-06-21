import 'package:crm_app/features/kpis/domain/domain.dart';

class KpisByAsesor {
  final String asesorNombre;
  final String asesorCodigo;
  final String asesorAbbrt;
  final double totalRegistro;
  final double porcentaje;
  final List<Kpi> semanal;
  final List<Kpi> mensual;
  final List<Kpi> anual;

  KpisByAsesor({
    required this.asesorNombre,
    required this.asesorCodigo,
    required this.asesorAbbrt,
    this.totalRegistro = 0,
    this.porcentaje = 0,
    this.semanal = const [],
    this.mensual = const [],
    this.anual = const [],
  });
}

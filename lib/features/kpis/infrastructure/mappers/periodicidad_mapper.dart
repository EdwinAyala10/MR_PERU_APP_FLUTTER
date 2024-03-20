import 'package:crm_app/features/kpis/domain/entities/periodicidad.dart';

class PeriodicidadMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Periodicidad(
    periIdPeriodicidad: json['PERI_ID_PERIODICIDAD'] ?? '',
    peobIdPeriodicidad: json['PERI_ID_PERIODICIDAD'] ?? '',
    periCodigo: json['PERI_CODIGO'] ?? '',
    periNombre: json['PERI_NOMBRE'] ?? '',
  );

}
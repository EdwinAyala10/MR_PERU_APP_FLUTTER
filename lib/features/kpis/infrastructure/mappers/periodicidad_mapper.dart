import '../../domain/entities/periodicidad.dart';

class PeriodicidadMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Periodicidad(
    periIdPeriodicidadCalendario: json['PERI_ID_PERIODICIDAD_CALENDARIO'] ?? '',
    peobIdPeriodicidadCalendario: json['PEOB_ID_PERIODICIDAD_CALENDARIO'] ?? '',
    peobIdPeriodicidad: json['PEOB_ID_PERIODICIDAD_CALENDARIO'] ?? '',
    periCodigo: json['PERI_CODIGO'] ?? '',
    periNombre: json['PERI_NOMBRE'] ?? '',
  );

}

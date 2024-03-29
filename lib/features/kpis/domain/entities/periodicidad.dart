import 'dart:convert';

Periodicidad periodicidadFromJson(String str) =>
    Periodicidad.fromJson(json.decode(str));

String periodicidadToJson(Periodicidad data) => json.encode(data.toJson());

class Periodicidad {
  String? periIdPeriodicidad;
  String? periCodigo;
  String? periNombre;
  String? peobIdPeriodicidad;
  String? peobCantidad;

  Periodicidad({
    this.periIdPeriodicidad,
    this.peobIdPeriodicidad,
    this.periCodigo,
    this.periNombre,
    this.peobCantidad,
  });

  factory Periodicidad.fromJson(Map<String, dynamic> json) => Periodicidad(
        periIdPeriodicidad: json["PERI_ID_PERIODICIDAD_CALENDARIO"],
        periCodigo: json["PERI_CODIGO"],
        periNombre: json["PERI_NOMBRE"],
        peobIdPeriodicidad: json["PEOB_ID_PERIODICIDAD"],
        peobCantidad: json["PEOB_CANTIDAD"],
      );

  Map<String, dynamic> toJson() => {
        "PERI_ID_PERIODICIDAD_CALENDARIO": periIdPeriodicidad,
        "PEOB_ID_PERIODICIDAD": peobIdPeriodicidad,
        "PERI_CODIGO": periCodigo,
        "PERI_NOMBRE": periNombre,
        "PEOB_CANTIDAD": peobCantidad,
      };
}

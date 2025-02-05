import 'dart:convert';

Periodicidad periodicidadFromJson(String str) =>
    Periodicidad.fromJson(json.decode(str));

String periodicidadToJson(Periodicidad data) => json.encode(data.toJson());

class Periodicidad {
  //String? periIdPeriodicidad;
  String? periIdPeriodicidadCalendario;
  String? peobIdPeriodicidadCalendario;
  String? periCodigo;
  String? peobIdObjetivo;
  String? periNombre;
  String? peobIdPeriodicidad;
  String? peobCantidad;
  String? peoIdObjetivoPeriodicidad;

  Periodicidad({
    //this.periIdPeriodicidad,
    this.periIdPeriodicidadCalendario,
    this.peobIdPeriodicidad,
    this.peobIdPeriodicidadCalendario,
    this.periCodigo,
    this.peobIdObjetivo,
    this.periNombre,
    this.peobCantidad,
    this.peoIdObjetivoPeriodicidad
  });

  factory Periodicidad.fromJson(Map<String, dynamic> json) => Periodicidad(
        //periIdPeriodicidad: json["PERI_ID_PERIODICIDAD_CALENDARIO"],
        periIdPeriodicidadCalendario: json["PERI_ID_PERIODICIDAD_CALENDARIO"],
        peobIdPeriodicidadCalendario: json["PEOB_ID_PERIODICIDAD_CALENDARIO"],
        peoIdObjetivoPeriodicidad: json["PEOB_ID_OBJETIVO_PERIODICIDAD"],
        periCodigo: json["PERI_CODIGO"],
        peobIdObjetivo: json["PEOB_ID_OBJETIVO"],
        periNombre: json["PERI_NOMBRE"],
        peobIdPeriodicidad: json["PEOB_ID_PERIODICIDAD"],
        peobCantidad: json["PEOB_CANTIDAD"],
      );

  Map<String, dynamic> toJson() => {
        //"PERI_ID_PERIODICIDAD_CALENDARIO": periIdPeriodicidad,
        "PERI_ID_PERIODICIDAD_CALENDARIO": periIdPeriodicidadCalendario,
        "PEOB_ID_PERIODICIDAD_CALENDARIO": peobIdPeriodicidadCalendario,
        "PEOB_ID_OBJETIVO_PERIODICIDAD": peoIdObjetivoPeriodicidad,
        "PEOB_ID_PERIODICIDAD": peobIdPeriodicidad,
        "PEOB_ID_OBJETIVO": peobIdObjetivo,
        "PERI_CODIGO": periCodigo,
        "PERI_NOMBRE": periNombre,
        "PEOB_CANTIDAD": peobCantidad,
      };
}


class ValidateEventPlanner {
  int? totalDias;
  int? totalLocales;
  String? fechaIni;
  String? fechaFin;

  ValidateEventPlanner({this.totalLocales, this.totalDias, this.fechaIni, this.fechaFin});

  factory ValidateEventPlanner.fromJson(Map<String, dynamic> json) => ValidateEventPlanner(
        totalLocales: json["TOTAL_LOCALES"],
        totalDias: json["TOTAL_DIAS"],
        fechaIni: json["FECHAINI"],
        fechaFin: json["FECHAFIN"],
      );

  Map<String, dynamic> toJson() => {
        "TOTTOTAL_LOCALESAL_DIAS": totalDias,
        "TOTAL_DIAS": totalDias,
        "FECHAINI": fechaIni,
        "FECHAFIN": fechaFin,
      };
}
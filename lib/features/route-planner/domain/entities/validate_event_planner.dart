
class ValidateEventPlanner {
  String? totalDias;
  String? fechaIni;
  String? fechaFin;

  ValidateEventPlanner({this.totalDias, this.fechaIni, this.fechaFin});

  factory ValidateEventPlanner.fromJson(Map<String, dynamic> json) => ValidateEventPlanner(
        totalDias: json["TOTAL_DIAS"],
        fechaIni: json["FECHAINI"],
        fechaFin: json["FECHAFIN"],
      );

  Map<String, dynamic> toJson() => {
        "TOTAL_DIAS": totalDias,
        "FECHAINI": fechaIni,
        "FECHAFIN": fechaFin,
      };
}
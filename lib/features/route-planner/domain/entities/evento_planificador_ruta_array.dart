class EventoPlanificadorRutaArray {
  String evntRuc;
  int evntLocalCodigo;

  EventoPlanificadorRutaArray({
    required this.evntRuc,
    required this.evntLocalCodigo
  });

  factory EventoPlanificadorRutaArray.fromJson(Map<String, dynamic> json) => EventoPlanificadorRutaArray(
    evntRuc: json["EVNT_RUC"],
    evntLocalCodigo: json["EVNT_LOCAL_CODIGO"],
  );

  Map<String, dynamic> toJson() => {
    "EVNT_RUC": evntRuc,
    "EVNT_LOCAL_CODIGO": evntLocalCodigo,
  };
}


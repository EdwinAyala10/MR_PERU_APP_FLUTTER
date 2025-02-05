class ResponsableArray {
  String? ecntIdResponsable;
  String? ecntIdEventoInvResp;
  String? userreportName;
  String? nombre;

  ResponsableArray({this.ecntIdResponsable, this.ecntIdEventoInvResp, this.nombre, this.userreportName});

  factory ResponsableArray.fromJson(Map<String, dynamic> json) => ResponsableArray(
        ecntIdResponsable: json["ERES_ID_USUARIO_RESPONSABLE"],
        ecntIdEventoInvResp: json["ERES_ID_EVENTO_INV_RESP"],
        userreportName: json["USERREPORT_NAME"],
        nombre: json["NOMBRE"],
      );

  Map<String, dynamic> toJson() => {
        "ERES_ID_USUARIO_RESPONSABLE": ecntIdResponsable,
        "ERES_ID_EVENTO_INV_RESP": ecntIdEventoInvResp,
        "USERREPORT_NAME": userreportName,
        "NOMBRE": nombre,
      };
}

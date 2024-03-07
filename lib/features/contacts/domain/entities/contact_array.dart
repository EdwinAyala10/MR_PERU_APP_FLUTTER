class ContactArray {
  String? ecntIdContacto;
  String? ecntIdEventoInvCnt;
  String? nombre;

  ContactArray({this.ecntIdContacto, this.ecntIdEventoInvCnt, this.nombre});

  factory ContactArray.fromJson(Map<String, dynamic> json) => ContactArray(
        ecntIdContacto: json["ECNT_ID_CONTACTO"],
        ecntIdEventoInvCnt: json["ECNT_ID_EVENTO_INV_CNT"],
        nombre: json["NOMBRE"],
      );

  Map<String, dynamic> toJson() => {
        "ECNT_ID_CONTACTO": ecntIdContacto,
        "ECNT_ID_EVENTO_INV_CNT": ecntIdEventoInvCnt,
        "NOMBRE": nombre,
      };
}

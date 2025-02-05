class ContactArray {
  String? ecntIdContacto;
  String? ecntIdEventoInvCnt;
  String? nombre;
  String? contactoDesc;
  String? acntIdContacto;
  String? acntIdActividadContacto;

  ContactArray(
      {this.ecntIdContacto,
      this.ecntIdEventoInvCnt,
      this.nombre,
      this.contactoDesc,
      this.acntIdContacto,
      this.acntIdActividadContacto});

  factory ContactArray.fromJson(Map<String, dynamic> json) => ContactArray(
        ecntIdContacto: json["ECNT_ID_CONTACTO"],
        ecntIdEventoInvCnt: json["ECNT_ID_EVENTO_INV_CNT"],
        nombre: json["NOMBRE"],
        contactoDesc: json["CONTACTO_DESC"],
        acntIdContacto: json["ACNT_ID_CONTACTO"],
        acntIdActividadContacto: json["ACNT_ID_ACTIVIDAD_CONTACTO"],
      );

  Map<String, dynamic> toJson() => {
        "ECNT_ID_CONTACTO": ecntIdContacto,
        "ECNT_ID_EVENTO_INV_CNT": ecntIdEventoInvCnt,
        "NOMBRE": nombre,
        "CONTACTO_DESC": contactoDesc,
        "ACNT_ID_CONTACTO": acntIdContacto,
        "ACNT_ID_ACTIVIDAD_CONTACTO": acntIdActividadContacto,
      };
}

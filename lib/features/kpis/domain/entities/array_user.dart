import 'dart:convert';

ArrayUser arrayUserFromJson(String str) => ArrayUser.fromJson(json.decode(str));

String arrayUserToJson(ArrayUser data) => json.encode(data.toJson());

class ArrayUser {
    String? id;
    String? cresIdClienteResp;
    String? idResponsable;
    String? cresIdUsuarioResponsable;
    String? name;
    String? nombreResponsable;
    String? userreportName;

    ArrayUser({
        this.id,
        this.idResponsable,
        this.cresIdUsuarioResponsable,
        this.cresIdClienteResp,
        this.name,
        this.nombreResponsable,
        this.userreportName,
    });

    factory ArrayUser.fromJson(Map<String, dynamic> json) => ArrayUser(
        id: json["OBUA_ID_USUARIO_ASIGNACION"],
        cresIdClienteResp: json["CRES_ID_CLIENTE_RESP"],
        cresIdUsuarioResponsable: json["CRES_ID_USUARIO_RESPONSABLE"],
        idResponsable: json["ID_USUARIO_RESPONSABLE"],
        name: json["NOMBRE"],
        nombreResponsable: json["NOMBRE_RESPONSABLE"],
        userreportName: json["USERREPORT_NAME"],
    );

    Map<String, dynamic> toJson() => {
        "OBUA_ID_USUARIO_ASIGNACION": id,
        "ID_USUARIO_RESPONSABLE": idResponsable,
        "CRES_ID_USUARIO_RESPONSABLE": cresIdUsuarioResponsable,
        "CRES_ID_CLIENTE_RESP": cresIdClienteResp,
        "NOMBRE": name,
        "NOMBRE_RESPONSABLE": nombreResponsable,
        "USERREPORT_NAME": userreportName,
    };
}

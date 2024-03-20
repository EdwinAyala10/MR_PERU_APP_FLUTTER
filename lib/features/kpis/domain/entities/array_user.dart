import 'dart:convert';

ArrayUser arrayUserFromJson(String str) => ArrayUser.fromJson(json.decode(str));

String arrayUserToJson(ArrayUser data) => json.encode(data.toJson());

class ArrayUser {
    String? id;
    String? idResponsable;
    String? name;
    String? userreportName;

    ArrayUser({
        this.id,
        this.idResponsable,
        this.name,
        this.userreportName,
    });

    factory ArrayUser.fromJson(Map<String, dynamic> json) => ArrayUser(
        id: json["OBUA_ID_USUARIO_ASIGNACION"],
        idResponsable: json["ID_USUARIO_RESPONSABLE"],
        name: json["NOMBRE"],
        userreportName: json["USERREPORT_NAME"],
    );

    Map<String, dynamic> toJson() => {
        "OBUA_ID_USUARIO_ASIGNACION": id,
        "ID_USUARIO_RESPONSABLE": idResponsable,
        "NOMBRE": name,
        "USERREPORT_NAME": userreportName,
    };
}

import 'dart:convert';

ArrayUser arrayUserFromJson(String str) => ArrayUser.fromJson(json.decode(str));

String arrayUserToJson(ArrayUser data) => json.encode(data.toJson());

class ArrayUser {
    String? id;
    String? name;

    ArrayUser({
        this.id,
        this.name,
    });

    factory ArrayUser.fromJson(Map<String, dynamic> json) => ArrayUser(
        id: json["OBUA_ID_USUARIO_ASIGNACION"],
        name: json["NOMBRE"],
    );

    Map<String, dynamic> toJson() => {
        "OBUA_ID_USUARIO_ASIGNACION": id,
        "NOMBRE": name,
    };
}

import 'dart:convert';

UsuarioAsignado usuarioAsignadoFromJson(String str) => UsuarioAsignado.fromJson(json.decode(str));

String usuarioAsignadoToJson(UsuarioAsignado data) => json.encode(data.toJson());

class UsuarioAsignado {
    String? userreportName;
    String? userreportCodigo;

    UsuarioAsignado({
        this.userreportName,
        this.userreportCodigo,
    });

    factory UsuarioAsignado.fromJson(Map<String, dynamic> json) => UsuarioAsignado(
        userreportName: json["USERREPORT_NAME"],
        userreportCodigo: json["USERREPORT_CODIGO"],
    );

    Map<String, dynamic> toJson() => {
        "USERREPORT_NAME": userreportName,
        "USERREPORT_CODIGO": userreportCodigo,
    };
}

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
    String icon;
    bool status;
    String message;
    String ?token;
    Data ?data;

    LoginResponse({
        required this.icon,
        required this.status,
        required this.message,
        this.token,
        required this.data,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        icon: json["icon"],
        status: json["status"],
        message: json["message"],
        token: json["token"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "icon": icon,
        "status": status,
        "message": message,
        "token": token,
        "data": data?.toJson(),
    };
}

class Data {
    int userreportId;
    String userreportCodigo;
    String userreportEmail;
    String userreportName;
    String userreportType;
    List<String> userreportRoles;

    Data({
        required this.userreportId,
        required this.userreportCodigo,
        required this.userreportEmail,
        required this.userreportName,
        required this.userreportType,
        required this.userreportRoles,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        userreportId: json["USERREPORT_ID"],
        userreportCodigo: json["USERREPORT_CODIGO"],
        userreportEmail: json["USERREPORT_EMAIL"],
        userreportName: json["USERREPORT_NAME"],
        userreportType: json["USERREPORT_TYPE"],
        userreportRoles: List<String>.from(json["USERREPORT_ROLES"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "USERREPORT_ID": userreportId,
        "USERREPORT_CODIGO": userreportCodigo,
        "USERREPORT_EMAIL": userreportEmail,
        "USERREPORT_NAME": userreportName,
        "USERREPORT_TYPE": userreportType,
        "USERREPORT_ROLES": List<dynamic>.from(userreportRoles.map((x) => x)),
    };
}

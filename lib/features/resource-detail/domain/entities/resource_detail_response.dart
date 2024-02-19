import 'dart:convert';

import 'package:crm_app/features/resource-detail/domain/domain.dart';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
    String type;
    String icon;
    bool status;
    String message;
    List<ResourceDetail> data;

    LoginResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        required this.data,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        type: json["type"],
        icon: json["icon"],
        status: json["status"],
        message: json["message"],
        data: List<ResourceDetail>.from(json["data"].map((x) => ResourceDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "icon": icon,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}


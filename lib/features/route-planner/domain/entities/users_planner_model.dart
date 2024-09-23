// To parse this JSON data, do
//
//     final usersPlannerModel = usersPlannerModelFromJson(jsonString);

import 'dart:convert';

UsersPlannerModel usersPlannerModelFromJson(String str) =>
    UsersPlannerModel.fromJson(json.decode(str));

String usersPlannerModelToJson(UsersPlannerModel data) =>
    json.encode(data.toJson());

class UsersPlannerModel {
  String? id;
  String? userreportCodigo;
  String? userreportEmail;
  String? userreportName;
  String? userreportType;
  String? userreportAbbrt;

  UsersPlannerModel({
    this.id,
    this.userreportCodigo,
    this.userreportEmail,
    this.userreportName,
    this.userreportType,
    this.userreportAbbrt,
  });

  factory UsersPlannerModel.fromJson(Map<String, dynamic> json) =>
      UsersPlannerModel(
        id: json["ID"],
        userreportCodigo: json["USERREPORT_CODIGO"],
        userreportEmail: json["USERREPORT_EMAIL"],
        userreportName: json["USERREPORT_NAME"],
        userreportType: json["USERREPORT_TYPE"],
        userreportAbbrt: json["USERREPORT_ABBRT"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "USERREPORT_CODIGO": userreportCodigo,
        "USERREPORT_EMAIL": userreportEmail,
        "USERREPORT_NAME": userreportName,
        "USERREPORT_TYPE": userreportType,
        "USERREPORT_ABBRT": userreportAbbrt,
      };
}
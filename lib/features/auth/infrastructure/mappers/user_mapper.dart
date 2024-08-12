import '../../domain/domain.dart';

class UserMapper {
  static User userJsonToEntity(Map<dynamic, dynamic> json) => User(
        id: json['data']['USERREPORT_ID'] ?? '',
        code: json['data']['USERREPORT_CODIGO'] ?? '',
        email: json['data']['USERREPORT_EMAIL'] ?? '',
        name: json['data']['USERREPORT_NAME'] ?? '',
        //roles: List<Rol>.from(json['data']['USERREPORT_ROLES'].map((role) => role)),
        roles: json['data']['USERREPORT_ROLES'] != null ? List<Rol>.from(json['data']['USERREPORT_ROLES'].map((x) => Rol.fromJson(x))) : [],
        type: json['data']['USERREPORT_TYPE'],
        token: json['token'] ?? '');
}

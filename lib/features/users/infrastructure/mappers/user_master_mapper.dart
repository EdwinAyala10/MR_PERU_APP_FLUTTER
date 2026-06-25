import '../../domain/domain.dart';

class UserMasterMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) => UserMaster(
      id: json['ID'] ?? '',
      code: json['USERREPORT_CODIGO'] ?? '',
      email: json['USERREPORT_EMAIL'] ?? '',
      name: json['USERREPORT_NAME'] ?? '',
      type: json['USERREPORT_TYPE'] ?? '',
      abbrt: json['USERREPORT_ABBRT'] ?? '');

  static List<UserMaster> jsonToListEntity(Map<dynamic, dynamic> json) {
    final List<UserMaster> users = [];
    for (final user in json['data'] ?? []) {
      users.add(jsonToEntity(user));
    }
    return users;
  }
}

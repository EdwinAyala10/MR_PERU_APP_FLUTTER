import '../../domain/domain.dart';


class UserMasterMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => UserMaster(
    id: json['ID'] ?? '',
    code: json['USERREPORT_CODIGO'] ?? '',
    email: json['USERREPORT_EMAIL'] ?? '',
    name: json['USERREPORT_NAME'] ?? '',
    type: json['USERREPORT_TYPE'] ?? ''
  );

}

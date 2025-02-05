import '../../domain/domain.dart';

class CompanyCheckInResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CompanyCheckInResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

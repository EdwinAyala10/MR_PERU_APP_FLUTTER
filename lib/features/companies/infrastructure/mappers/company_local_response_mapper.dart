import '../../domain/domain.dart';

class CompanyLocalResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CompanyLocalResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

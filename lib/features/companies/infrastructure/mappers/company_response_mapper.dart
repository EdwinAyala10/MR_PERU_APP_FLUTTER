import '../../domain/domain.dart';

class CompanyResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CompanyResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

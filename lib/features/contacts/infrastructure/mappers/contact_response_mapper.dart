import '../../domain/domain.dart';

class ContactResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ContactResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

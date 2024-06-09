import '../../domain/domain.dart';

class DocumentResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => DocumentResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
  );

}

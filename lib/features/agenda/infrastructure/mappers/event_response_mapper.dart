import 'package:crm_app/features/agenda/domain/domain.dart';

class EventResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => EventResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

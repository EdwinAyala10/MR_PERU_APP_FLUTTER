import 'package:crm_app/features/activities/domain/domain.dart';

class ActivityResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ActivityResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

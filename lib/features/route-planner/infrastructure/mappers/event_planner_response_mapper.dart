import 'package:crm_app/features/route-planner/domain/entities/event_planner_response.dart';

class EventPlannerResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => EventPlannerResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

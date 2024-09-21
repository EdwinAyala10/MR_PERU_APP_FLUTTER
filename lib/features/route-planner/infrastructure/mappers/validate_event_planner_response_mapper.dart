
import 'package:crm_app/features/route-planner/domain/entities/validate_event_planner_response.dart';

class ValidateEventPlannerResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ValidateEventPlannerResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );
}

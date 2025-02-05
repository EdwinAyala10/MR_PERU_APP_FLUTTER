

import 'package:crm_app/features/route-planner/domain/entities/validate_event_planner.dart';

class ValidateEventPlannerResponse {
    String type;
    String icon;
    bool status;
    String message;
    ValidateEventPlanner? data;

    ValidateEventPlannerResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.data,
    });
}

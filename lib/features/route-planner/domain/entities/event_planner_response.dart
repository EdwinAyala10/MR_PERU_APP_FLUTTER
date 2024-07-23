
import 'package:crm_app/features/route-planner/domain/entities/event_planner.dart';

class EventPlannerResponse {
    String type;
    String icon;
    bool status;
    String message;
    EventPlanner? event;

    EventPlannerResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.event,
    });
}

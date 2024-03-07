import 'package:crm_app/features/agenda/domain/entities/event.dart';

class EventResponse {
    String type;
    String icon;
    bool status;
    String message;
    Event? event;

    EventResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.event,
    });
}

import 'package:crm_app/features/activities/domain/domain.dart';

class ActivityResponse {
    String type;
    String icon;
    bool status;
    String message;
    Activity? activity;

    ActivityResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.activity,
    });
}

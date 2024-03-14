import 'package:crm_app/features/kpis/domain/domain.dart';

class KpiResponse {
    String type;
    String icon;
    bool status;
    String message;
    Kpi? kpi;

    KpiResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.kpi,
    });
}

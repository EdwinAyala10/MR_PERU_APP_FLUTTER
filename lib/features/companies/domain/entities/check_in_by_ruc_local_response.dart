import 'package:crm_app/features/companies/domain/entities/check_in_by_ruc_local.dart';

class CheckInByRucLocalResponse {
    String type;
    String icon;
    bool status;
    String message;
    CheckInByRucLocal? checkInByRucLocal;

    CheckInByRucLocalResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.checkInByRucLocal,
    });

}

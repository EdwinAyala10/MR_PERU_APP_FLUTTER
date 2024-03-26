import 'package:crm_app/features/companies/domain/domain.dart';

class CompanyLocalResponse {
    String type;
    String icon;
    bool status;
    String message;
    CompanyLocal? companyLocal;

    CompanyLocalResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.companyLocal,
    });
}

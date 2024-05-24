import '../domain.dart';

class CompanyResponse {
    String type;
    String icon;
    bool status;
    String message;
    Company? company;

    CompanyResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.company,
    });
}

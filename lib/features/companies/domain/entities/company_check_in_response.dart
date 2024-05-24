import '../domain.dart';

class CompanyCheckInResponse {
    String type;
    String icon;
    bool status;
    String message;
    CompanyCheckIn? companyCheckIn;

    CompanyCheckInResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.companyCheckIn,
    });
}

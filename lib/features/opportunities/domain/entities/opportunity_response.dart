import '../domain.dart';

class OpportunityResponse {
    String type;
    String icon;
    bool status;
    String message;
    Opportunity? opportunity;

    OpportunityResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.opportunity,
    });
}

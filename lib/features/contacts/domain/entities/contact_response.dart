import '../domain.dart';

class ContactResponse {
    String type;
    String icon;
    bool status;
    String message;
    Contact? contact;

    ContactResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.contact,
    });
}



import 'package:crm_app/features/documents/domain/domain.dart';

class DocumentResponse {
    String icon;
    bool status;
    String message;
    Document? document;

    DocumentResponse({
        required this.icon,
        required this.status,
        required this.message,
        this.document,
    });
}

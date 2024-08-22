import 'package:crm_app/features/activities/domain/entities/activitie_document.dart';

class ACDocumentResponse {
  String icon;
  bool status;
  String message;
  ACDocument? document;

  ACDocumentResponse({
    required this.icon,
    required this.status,
    required this.message,
    this.document,
  });
}

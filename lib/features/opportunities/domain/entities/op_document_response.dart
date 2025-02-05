import 'package:crm_app/features/opportunities/domain/entities/op_document.dart';

class OPDocumentResponse {
  String icon;
  bool status;
  String message;
  OpDocument? document;

  OPDocumentResponse({
    required this.icon,
    required this.status,
    required this.message,
    this.document,
  });
}

import 'package:crm_app/features/opportunities/domain/entities/doc_opportunitie.dart';

class DocOpportunitieResponse {
  String icon;
  bool status;
  String message;
  DocumentOpportunitie? document;

  DocOpportunitieResponse({
    required this.icon,
    required this.status,
    required this.message,
    this.document,
  });
}

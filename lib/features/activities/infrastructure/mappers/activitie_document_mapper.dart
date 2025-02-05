import 'package:crm_app/features/activities/domain/entities/activitie_document.dart';

class ACDocumentMapper {
  static jsonToEntity(Map<String, dynamic> json) => ACDocument.fromJson(json);
}

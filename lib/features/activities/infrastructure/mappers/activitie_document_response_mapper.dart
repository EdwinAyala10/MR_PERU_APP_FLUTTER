import 'package:crm_app/features/activities/domain/entities/activitie_document_response.dart';

class ACDocumentResponseMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) => ACDocumentResponse(
        icon: json['icon'],
        message: json['message'],
        status: json['status'],
      );
}

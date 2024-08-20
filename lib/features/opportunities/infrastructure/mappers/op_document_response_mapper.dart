import 'package:crm_app/features/opportunities/domain/entities/op_document_response.dart';

class OPDocumentResponseMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) => OPDocumentResponse(
        icon: json['icon'],
        message: json['message'],
        status: json['status'],
      );
}

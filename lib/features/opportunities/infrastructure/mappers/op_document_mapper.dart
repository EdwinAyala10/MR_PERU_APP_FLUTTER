import 'package:crm_app/features/opportunities/domain/entities/op_document.dart';

class OPDocumentMapper {
  static jsonToEntity(Map<String, dynamic> json) => OpDocument.fromJson(json);
}

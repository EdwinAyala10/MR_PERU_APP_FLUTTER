import 'package:crm_app/features/opportunities/domain/entities/op_document.dart';
import 'package:crm_app/features/opportunities/domain/entities/op_document_response.dart';

abstract class DocOpportunitieRepository {
  Future<List<OpDocument>> getDocuments({
    required String idOportunidad,
    required String idTypeAdjunto,
  });

  Future<OpDocument> getDocumentById(
    String id,
  );

  Future<OPDocumentResponse> createDocument(
    Map<dynamic, dynamic> documentLike,
  );

  Future<OPDocumentResponse> createEnlace(
    Map<dynamic, dynamic> enlaceLike,
  );

  Future<OPDocumentResponse> deleteDocumentLink(
    String idAdjunto,
    String idUserRegister
  );
}

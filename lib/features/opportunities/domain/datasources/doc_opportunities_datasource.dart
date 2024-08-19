import 'package:crm_app/features/opportunities/domain/entities/doc_opportunitie.dart';
import 'package:crm_app/features/opportunities/domain/entities/doc_opportunitie_response.dart';

abstract class DocOpportunitiesDatasource {
  Future<List<DocumentOpportunitie>> getDocuments({
    String idUsuario,
  });

  Future<DocumentOpportunitie> getDocumentById(
    String id,
  );

  Future<DocOpportunitieResponse> createDocument(
    Map<dynamic, dynamic> documentLike,
  );

  Future<DocOpportunitieResponse> createEnlace(
    Map<dynamic, dynamic> enlaceLike,
  );

  Future<DocOpportunitieResponse> deleteDocumentLink(
    String idAdjunto,
  );
}

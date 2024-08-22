import 'package:crm_app/features/activities/domain/entities/activitie_document.dart';
import 'package:crm_app/features/activities/domain/entities/activitie_document_response.dart';

abstract class DocActivitieRepository {
  Future<List<ACDocument>> getDocuments({
    required String idOportunidad,
    required String idTypeAdjunto,
  });

  Future<ACDocument> getDocumentById(
    String id,
  );

  Future<ACDocumentResponse> createDocument(
    Map<dynamic, dynamic> documentLike,
  );

  Future<ACDocumentResponse> createEnlace(
    Map<dynamic, dynamic> enlaceLike,
  );

  Future<ACDocumentResponse> deleteDocumentLink(
    String idAdjunto,
    String idUserRegister,
  );
}

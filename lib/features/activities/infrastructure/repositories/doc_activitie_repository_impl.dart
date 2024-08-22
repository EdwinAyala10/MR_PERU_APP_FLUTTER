import 'package:crm_app/features/activities/domain/datasources/doc_activities_datasource.dart';
import 'package:crm_app/features/activities/domain/entities/activitie_document.dart';
import 'package:crm_app/features/activities/domain/entities/activitie_document_response.dart';
import 'package:crm_app/features/activities/domain/repositories/doc_activitie_repository.dart';

class DocActivitieRepositoryImpl extends DocActivitieRepository {
  final DocActivitieDatasource datasource;

  DocActivitieRepositoryImpl(this.datasource);

  @override
  Future<ACDocumentResponse> createDocument(
      Map<dynamic, dynamic> documentLike) {
    return datasource.createDocument(documentLike);
  }

  @override
  Future<ACDocumentResponse> createEnlace(Map<dynamic, dynamic> enlaceLike) {
    return datasource.createEnlace(enlaceLike);
  }

  @override
  Future<ACDocument> getDocumentById(String id) {
    return datasource.getDocumentById(id);
  }

  @override
  Future<ACDocumentResponse> deleteDocumentLink(
    String idAdjunto,
    String idUserRegister,
  ) {
    return datasource.deleteDocumentLink(idAdjunto, idUserRegister);
  }

  @override
  Future<List<ACDocument>> getDocuments({
    required String idOportunidad,
    required String idTypeAdjunto,
  }) {
    return datasource.getDocuments(
      idOportunidad: idOportunidad,
      idTypeAdjunto: idTypeAdjunto,
    );
  }
}

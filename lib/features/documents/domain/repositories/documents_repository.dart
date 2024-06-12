import '../domain.dart';

abstract class DocumentsRepository {
  Future<List<Document>> getDocuments({String idUsuario});
  Future<Document> getDocumentById(String id);

  Future<DocumentResponse> createDocument(
      Map<dynamic, dynamic> documentLike);

  Future<DocumentResponse> createEnlace(
      Map<dynamic, dynamic> enlaceLike);
  
  Future<DocumentResponse> deleteDocumentLink(String idAdjunto);
}

import '../../domain/domain.dart';

class DocumentsRepositoryImpl extends DocumentsRepository {
  final DocumentsDatasource datasource;

  DocumentsRepositoryImpl(this.datasource);

  @override
  Future<DocumentResponse> createDocument(
      Map<dynamic, dynamic> documentLike) {
    return datasource.createDocument(documentLike);
  }

  @override
  Future<DocumentResponse> createEnlace(
      Map<dynamic, dynamic> enlaceLike) {
    return datasource.createEnlace(enlaceLike);
  }

  @override
  Future<Document> getDocumentById(String id) {
    return datasource.getDocumentById(id);
  }

  @override
  Future<List<Document>> getDocuments({String idUsuario = ''}) {
    return datasource.getDocuments(idUsuario: idUsuario);
  }

  @override
  Future<DocumentResponse> deleteDocumentLink(String idAdjunto) {
    return datasource.deleteDocumentLink(idAdjunto);
  }
  
}

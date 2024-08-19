import 'package:crm_app/features/opportunities/domain/datasources/doc_opportunities_datasource.dart';
import 'package:crm_app/features/opportunities/domain/entities/doc_opportunitie.dart';
import 'package:crm_app/features/opportunities/domain/entities/doc_opportunitie_response.dart';
import 'package:crm_app/features/opportunities/domain/repositories/doc_opportunitie_repository.dart';


class DocOpportunitieRepositoryImpl extends DocOpportunitieRepository {
  final DocOpportunitiesDatasource datasource;

  DocOpportunitieRepositoryImpl(this.datasource);

  @override
  Future<DocOpportunitieResponse> createDocument(Map<dynamic, dynamic> documentLike) {
    return datasource.createDocument(documentLike);
  }

  @override
  Future<DocOpportunitieResponse> createEnlace(Map<dynamic, dynamic> enlaceLike) {
    return datasource.createEnlace(enlaceLike);
  }

  @override
  Future<DocumentOpportunitie> getDocumentById(String id) {
    return datasource.getDocumentById(id);
  }

  @override
  Future<List<DocumentOpportunitie>> getDocuments({String idUsuario = ''}) {
    return datasource.getDocuments(idUsuario: idUsuario);
  }

  @override
  Future<DocOpportunitieResponse> deleteDocumentLink(String idAdjunto) {
    return datasource.deleteDocumentLink(idAdjunto);
  }
}

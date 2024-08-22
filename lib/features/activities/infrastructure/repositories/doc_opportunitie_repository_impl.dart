import 'package:crm_app/features/opportunities/domain/datasources/doc_opportunities_datasource.dart';
import 'package:crm_app/features/opportunities/domain/entities/op_document.dart';
import 'package:crm_app/features/opportunities/domain/entities/op_document_response.dart';
import 'package:crm_app/features/opportunities/domain/repositories/doc_opportunitie_repository.dart';

class DocOpportunitieRepositoryImpl extends DocOpportunitieRepository {
  final DocOpportunitiesDatasource datasource;

  DocOpportunitieRepositoryImpl(this.datasource);

  @override
  Future<OPDocumentResponse> createDocument(
      Map<dynamic, dynamic> documentLike) {
    return datasource.createDocument(documentLike);
  }

  @override
  Future<OPDocumentResponse> createEnlace(Map<dynamic, dynamic> enlaceLike) {
    return datasource.createEnlace(enlaceLike);
  }

  @override
  Future<OpDocument> getDocumentById(String id) {
    return datasource.getDocumentById(id);
  }

  @override
  Future<OPDocumentResponse> deleteDocumentLink(
    String idAdjunto,
    String idUserRegister,
  ) {
    return datasource.deleteDocumentLink(idAdjunto, idUserRegister);
  }

  @override
  Future<List<OpDocument>> getDocuments({
    required String idOportunidad,
    required String idTypeAdjunto,
  }) {
    return datasource.getDocuments(
      idOportunidad: idOportunidad,
      idTypeAdjunto: idTypeAdjunto,
    );
  }
}

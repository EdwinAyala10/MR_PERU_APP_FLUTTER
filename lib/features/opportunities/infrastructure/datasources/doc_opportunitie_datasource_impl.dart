import 'package:crm_app/features/opportunities/domain/datasources/doc_opportunities_datasource.dart';
import 'package:crm_app/features/opportunities/domain/entities/doc_opportunitie.dart';
import 'package:crm_app/features/opportunities/domain/entities/doc_opportunitie_response.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/features/documents/infrastructure/infrastructure.dart';

import '../../../../config/config.dart';

class DocOpportunitieDatasourceImpl extends DocOpportunitiesDatasource {
  late final Dio dio;
  final String accessToken;

  DocOpportunitieDatasourceImpl({required this.accessToken})
      : dio = Dio(
          BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

  @override
  Future<DocOpportunitieResponse> createDocument(
    Map<dynamic, dynamic> documentLike,
  ) async {
    try {
      const String url = '/archivos/request-file';

      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          documentLike['path']!,
          filename: documentLike['filename'],
        ),
        'ID_USUARIO_REGISTRO': documentLike['id_usuario_registro']
      });

      final response = await dio.post(url, data: formData);

      final DocOpportunitieResponse documentResponse =
          DocumentResponseMapper.jsonToEntity(response.data);

      if (documentResponse.status == true) {
        documentResponse.document =
            DocumentMapper.jsonToEntity(response.data['data'][0]);
      }

      return documentResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<DocOpportunitieResponse> createEnlace(
      Map<dynamic, dynamic> enlaceLike) async {
    try {
      const String url = '/archivos/guardar-enlace';

      final data = {
        'ADJT_ENLACE': enlaceLike['ADJT_ENLACE'],
        'ID_USUARIO_REGISTRO': enlaceLike['ID_USUARIO_REGISTRO']
      };

      final response = await dio.post(url, data: data);

      final DocOpportunitieResponse documentResponse =
          DocumentResponseMapper.jsonToEntity(response.data);

      if (documentResponse.status == true) {
        documentResponse.document =
            DocumentMapper.jsonToEntity(response.data['data'][0]);
      }

      return documentResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<DocOpportunitieResponse> deleteDocumentLink(String idAdjunto) async {
    try {
      const String url = '/archivos/eliminar-adjunto';

      final data = {
        'ADJT_ID_ADJUNTO': idAdjunto,
      };

      final response = await dio.post(url, data: data);

      final DocOpportunitieResponse documentResponse =
          DocumentResponseMapper.jsonToEntity(response.data);

      return documentResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<DocumentOpportunitie> getDocumentById(String id) async {
    try {
      final response = await dio.get('/archivos/listar-adjunto-by-id/$id');
      final DocumentOpportunitie document =
          DocumentMapper.jsonToEntity(response.data['data']);

      return document;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<DocumentOpportunitie>> getDocuments(
      {String idUsuario = ''}) async {
    final data = {"ID_USUARIO_REGISTRO": idUsuario};

    final response = await dio.post('/archivos/listar-adjuntos', data: data);
    final List<DocumentOpportunitie> documents = [];
    for (final document in response.data['data'] ?? []) {
      documents.add(DocumentMapper.jsonToEntity(document));
    }

    return documents;
  }
}

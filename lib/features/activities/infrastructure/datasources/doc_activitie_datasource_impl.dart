import 'package:crm_app/features/activities/domain/datasources/doc_activities_datasource.dart';
import 'package:crm_app/features/activities/domain/entities/activitie_document.dart';
import 'package:crm_app/features/activities/domain/entities/activitie_document_response.dart';
import 'package:crm_app/features/activities/infrastructure/mappers/activitie_document_mapper.dart';
import 'package:crm_app/features/activities/infrastructure/mappers/activitie_document_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/features/documents/infrastructure/infrastructure.dart';
import '../../../../config/config.dart';

class DocActivitieDatasourceImpl extends DocActivitieDatasource {
  late final Dio dio;
  final String accessToken;

  DocActivitieDatasourceImpl({required this.accessToken})
      : dio = Dio(
          BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

  @override
  Future<ACDocumentResponse> createDocument(
    Map<dynamic, dynamic> documentLike,
  ) async {
    try {
      const String url = '/actividad/guardar-actividad-adjunto';
      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          documentLike['path']!,
          filename: documentLike['filename'],
        ),
        'ID_USUARIO_REGISTRO': documentLike['ID_USUARIO_REGISTRO'],
        'ACDJ_ID_ACTIVIDAD': documentLike['ACDJ_ID_ACTIVIDAD'],
        'ACDJ_ID_TIPO_ADJUNTO': documentLike['ACDJ_ID_TIPO_ADJUNTO'],
      });

      final response = await dio.post(url, data: formData);
      final ACDocumentResponse documentResponse =
          ACDocumentResponseMapper.jsonToEntity(response.data);

      if (documentResponse.status == true) {
        documentResponse.document = ACDocumentMapper.jsonToEntity(
          response.data['data'][0],
        );
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
  Future<ACDocumentResponse> createEnlace(
      Map<dynamic, dynamic> enlaceLike) async {
    print("e.toString()");

    try {
      const String url = '/archivos/guardar-enlace';
      print("e.toString()");

      final data = {
        'ADJT_ENLACE': enlaceLike['ADJT_ENLACE'],
        'ID_USUARIO_REGISTRO': enlaceLike['ID_USUARIO_REGISTRO']
      };

      final response = await dio.post(url, data: data);

      final ACDocumentResponse documentResponse =
          ACDocumentResponseMapper.jsonToEntity(response.data);

      if (documentResponse.status == true) {
        documentResponse.document =
            ACDocumentMapper.jsonToEntity(response.data['data'][0]);
      }

      return documentResponse;
    } on DioException catch (e) {
      print(e.toString());

      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      print(e.toString());
      throw Exception();
    }
  }

  @override
  Future<ACDocumentResponse> deleteDocumentLink(
    String idAdjunto,
    String idUserRegister,
  ) async {
    try {
      const String url = '/actividad/eliminar-actividad-adjunto-por-id';

      final data = {
        'ID_USUARIO_REGISTRO': idUserRegister,
        'ACDJ_ID_ACTIVIDAD_ADJUNTO': idAdjunto,
      };

      final response = await dio.post(url, data: data);

      final ACDocumentResponse documentResponse =
          ACDocumentResponseMapper.jsonToEntity(response.data);

      return documentResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<ACDocument> getDocumentById(String id) async {
    try {
      final response = await dio.get('/archivos/listar-adjunto-by-id/$id');
      final ACDocument document =
          ACDocumentMapper.jsonToEntity(response.data['data']);

      return document;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<ACDocument>> getDocuments({
    required String idOportunidad,
    required String idTypeAdjunto,
  }) async {
    final data = {
      "ACDJ_ID_ACTIVIDAD": idOportunidad,
      "ACDJ_ID_TIPO_ADJUNTO": idTypeAdjunto
    };
    try {
      final response = await dio.post(
        '/actividad/listar-actividad-adjunto',
        data: data,
      );

      print(response.data);
      final List<ACDocument> documents = [];
      for (final document in response.data['data'] ?? []) {
        documents.add(ACDocumentMapper.jsonToEntity(document));
      }

      return documents;
    } on Exception catch (e) {
      print(e.toString());

      return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}

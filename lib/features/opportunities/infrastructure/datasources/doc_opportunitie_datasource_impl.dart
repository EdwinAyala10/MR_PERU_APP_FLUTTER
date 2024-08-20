import 'dart:developer';

import 'package:crm_app/features/opportunities/domain/datasources/doc_opportunities_datasource.dart';
import 'package:crm_app/features/opportunities/domain/entities/op_document.dart';
import 'package:crm_app/features/opportunities/domain/entities/op_document_response.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/op_document_mapper.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/op_document_response_mapper.dart';
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
  Future<OPDocumentResponse> createDocument(
    Map<dynamic, dynamic> documentLike,
  ) async {
    try {
      const String url = '/oportunidad/guardar-oportunidad-adjunto';
      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          documentLike['path']!,
          filename: documentLike['filename'],
        ),
        'ID_USUARIO_REGISTRO': documentLike['ID_USUARIO_REGISTRO'],
        'OADJ_ID_OPORTUNIDAD': documentLike['OADJ_ID_OPORTUNIDAD'],
        'OADJ_ID_TIPO_ADJUNTO': documentLike['OADJ_ID_TIPO_ADJUNTO'],
      });

      final response = await dio.post(url, data: formData);
      final OPDocumentResponse documentResponse =
          OPDocumentResponseMapper.jsonToEntity(response.data);

      if (documentResponse.status == true) {
        documentResponse.document = OPDocumentMapper.jsonToEntity(
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
  Future<OPDocumentResponse> createEnlace(
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

      final OPDocumentResponse documentResponse =
          OPDocumentResponseMapper.jsonToEntity(response.data);

      if (documentResponse.status == true) {
        documentResponse.document =
            DocumentMapper.jsonToEntity(response.data['data'][0]);
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
  Future<OPDocumentResponse> deleteDocumentLink(
    String idAdjunto,
    String idUserRegister,
  ) async {
    try {
      const String url = '/oportunidad/eliminar-oportunidad-adjunto-por-id';

      final data = {
        'ID_USUARIO_REGISTRO': idUserRegister,
        'OADJ_ID_OPORTUNIDAD_ADJUNTO': idAdjunto,
      };

      final response = await dio.post(url, data: data);

      final OPDocumentResponse documentResponse =
          OPDocumentResponseMapper.jsonToEntity(response.data);

      return documentResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<OpDocument> getDocumentById(String id) async {
    try {
      final response = await dio.get('/archivos/listar-adjunto-by-id/$id');
      final OpDocument document =
          OPDocumentMapper.jsonToEntity(response.data['data']);

      return document;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw DocumentNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<OpDocument>> getDocuments({
    required String idOportunidad,
    required String idTypeAdjunto,
  }) async {
    final data = {
      "OADJ_ID_OPORTUNIDAD": idOportunidad,
      "OADJ_ID_TIPO_ADJUNTO": idTypeAdjunto
    };
    try {
      final response =
          await dio.post('/oportunidad/listar-oportunidad-adjunto', data: data);

      final List<OpDocument> documents = [];
      for (final document in response.data['data'] ?? []) {
        documents.add(OPDocumentMapper.jsonToEntity(document));
      }

      return documents;
    } catch (e) {
      return [];
    }
  }
}

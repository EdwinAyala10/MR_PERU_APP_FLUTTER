import 'package:crm_app/features/shared/domain/datasources/email_datasource.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_request.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_response.dart';
import 'package:crm_app/features/shared/infrastructure/mappers/email_response_mapper.dart';
import 'package:crm_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class EmailDatasourceImpl extends EmailDatasource {
  final Dio dio;
  final String accessToken;

  EmailDatasourceImpl({
    required this.accessToken,
    Dio? dioClient,
  }) : dio = dioClient ??
            Dio(
              BaseOptions(
                baseUrl: Environment.apiUrl,
                // OPTIMIZACIÓN: Conexiones persistentes y compresión gzip
                connectTimeout: const Duration(seconds: 15),
                followRedirects: false,
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Accept-Encoding': 'gzip, deflate',
                  'Connection': 'keep-alive',
                },
              ),
            );

  @override
  Future<SendEmailResponse> sendEmail(SendEmailRequest request) async {
    final payloadMap = request.toFormData();

    try {
      // Construir FormData manualmente para manejar correctamente los archivos
      final formData = FormData();
      
      // Agregar todos los campos que no sean archivos
      payloadMap.forEach((key, value) {
        if (key != 'files[]' && key != 'files') {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });
      
      // Agregar archivos uno por uno con la clave 'files[]'
      for (final file in request.files) {
        formData.files.add(MapEntry('files[]', file));
      }

      final Response response = await dio.post(
        '/email/enviar-email-microsoft-graph',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          // OPTIMIZACIÓN: Timeouts ajustados
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 30),
          // OPTIMIZACIÓN: Pedir respuesta comprimida y simple
          headers: {
            'Accept': 'application/json',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
          },
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        return SendEmailResponse(
          success: false,
          message: 'Error ${response.statusCode}: endpoint de correo no disponible.',
        );
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return EmailResponseMapper.fromJson(data);
      }

      if (data is String && data.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return EmailResponseMapper.fromJson(decoded);
          }
        } catch (_) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            return SendEmailResponse(
              success: true,
              message: data,
              data: data,
            );
          }
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const SendEmailResponse(
          success: true,
          message: 'Tu correo electrónico ha sido enviado con éxito.',
        );
      }

      return SendEmailResponse(
        success: false,
        message: 'Respuesta inválida del servidor (status: ${response.statusCode}).',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return EmailResponseMapper.fromJson(data);
      }

      return SendEmailResponse(
        success: false,
        message: e.message ?? 'Error de conexión al enviar correo',
      );
    }
  }

}

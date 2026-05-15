import 'package:crm_app/features/shared/domain/datasources/email_datasource.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_request.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_response.dart';
import 'package:crm_app/features/shared/infrastructure/mappers/email_response_mapper.dart';
import 'package:crm_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer';

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
                headers: {'Authorization': 'Bearer $accessToken'},
              ),
            );

  @override
  Future<SendEmailResponse> sendEmail(SendEmailRequest request) async {
    final payloadMap = request.toFormData();

    try {
      log('EMAIL DEBUG -> baseUrl: ${dio.options.baseUrl}');
      log('EMAIL DEBUG -> endpoint: /email/enviar-email');
      log('EMAIL DEBUG -> authHeader: ${dio.options.headers['Authorization']}');
      log('EMAIL DEBUG -> payload keys: ${payloadMap.keys.toList()}');

      final Response response = await dio.post(
        '/email/enviar-email',
        data: FormData.fromMap(payloadMap),
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      log('EMAIL DEBUG -> statusCode: ${response.statusCode}');
      log('EMAIL DEBUG -> location: ${response.headers.value('location')}');
      log('EMAIL DEBUG -> responseType: ${response.data.runtimeType}');
      log('EMAIL DEBUG -> responseData: ${response.data}');

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
          message: 'Correo enviado correctamente.',
        );
      }

      return SendEmailResponse(
        success: false,
        message: 'Respuesta inválida del servidor (status: ${response.statusCode}).',
      );
    } on DioException catch (e) {
      log('EMAIL DEBUG -> DioException status: ${e.response?.statusCode}');
      log('EMAIL DEBUG -> DioException location: ${e.response?.headers.value('location')}');
      log('EMAIL DEBUG -> DioException data: ${e.response?.data}');
      log('EMAIL DEBUG -> DioException message: ${e.message}');
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

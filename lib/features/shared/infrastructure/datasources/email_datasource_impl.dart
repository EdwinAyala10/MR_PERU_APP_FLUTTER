import 'package:crm_app/features/shared/domain/datasources/email_datasource.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_request.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_response.dart';
import 'package:crm_app/features/shared/infrastructure/mappers/email_response_mapper.dart';
import 'package:crm_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
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
                headers: {'Authorization': 'Bearer $accessToken'},
              ),
            );

  @override
  Future<SendEmailResponse> sendEmail(SendEmailRequest request) async {
    final payloadMap = request.toFormData();

    try {
      final Response response = await dio.post(
        '/email/enviar-email-microsoft-graph',
        data: FormData.fromMap(payloadMap),
        options: Options(
          validateStatus: (status) => status != null && status < 500,
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

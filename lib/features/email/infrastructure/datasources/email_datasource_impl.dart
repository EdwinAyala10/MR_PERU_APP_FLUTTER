import 'package:crm_app/features/email/domain/datasources/email_datasource.dart';
import 'package:crm_app/features/email/domain/entities/send_email_request.dart';
import 'package:crm_app/features/email/domain/entities/send_email_response.dart';
import 'package:crm_app/features/email/infrastructure/mappers/email_response_mapper.dart';
import 'package:dio/dio.dart';

class EmailDatasourceImpl extends EmailDatasource {
  final Dio dio;

  EmailDatasourceImpl({Dio? dioClient}) : dio = dioClient ?? Dio();

  @override
  Future<SendEmailResponse> sendEmail(SendEmailRequest request) async {
    try {
      final response = await dio.post(
        'http://157.245.242.236:8080/api/email/enviar-email',
        data: FormData.fromMap(request.toJson()),
      );

      if (response.data is Map<String, dynamic>) {
        return EmailResponseMapper.fromJson(response.data as Map<String, dynamic>);
      }

      return const SendEmailResponse(
        success: false,
        message: 'Respuesta inválida del servidor',
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

import 'package:crm_app/features/shared/domain/entities/send_email_response.dart';

class EmailResponseMapper {
  static SendEmailResponse fromJson(Map<String, dynamic> json) {
    return SendEmailResponse(
      success: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? 'Sin mensaje',
      data: json['data'],
    );
  }
}

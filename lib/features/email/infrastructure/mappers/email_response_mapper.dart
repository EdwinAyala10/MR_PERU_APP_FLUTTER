import 'package:crm_app/features/email/domain/entities/send_email_response.dart';

class EmailResponseMapper {
  static SendEmailResponse fromJson(Map<String, dynamic> json) {
    return SendEmailResponse(
      success: json['status'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

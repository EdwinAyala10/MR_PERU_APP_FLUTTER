import '../entities/send_email_request.dart';
import '../entities/send_email_response.dart';

abstract class EmailDatasource {
  Future<SendEmailResponse> sendEmail(SendEmailRequest request);
}

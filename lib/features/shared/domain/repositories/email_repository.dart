import '../entities/send_email_request.dart';
import '../entities/send_email_response.dart';

abstract class EmailRepository {
  Future<SendEmailResponse> sendEmail(SendEmailRequest request);
}

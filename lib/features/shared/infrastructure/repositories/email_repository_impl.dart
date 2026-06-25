import 'package:crm_app/features/shared/domain/datasources/email_datasource.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_request.dart';
import 'package:crm_app/features/shared/domain/entities/send_email_response.dart';
import 'package:crm_app/features/shared/domain/repositories/email_repository.dart';

class EmailRepositoryImpl extends EmailRepository {
  final EmailDatasource datasource;

  EmailRepositoryImpl(this.datasource);

  @override
  Future<SendEmailResponse> sendEmail(SendEmailRequest request) {
    return datasource.sendEmail(request);
  }
}

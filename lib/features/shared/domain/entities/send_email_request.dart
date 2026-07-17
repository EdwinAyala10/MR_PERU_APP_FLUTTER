import 'email_recipient.dart';
import 'package:dio/dio.dart';

class SendEmailRequest {
  final String usuarioResponsableId;
  final String ruc;
  final String contactoId;
  final String asunto;
  final String comentario;
  final String userEmail;
  final String emailFrom;
  final String oportunidadId;
  final List<EmailRecipient> recipients;
  final List<MultipartFile> files;
  final List<Map<String, dynamic>> oportunidadEntries;

  const SendEmailRequest({
    required this.usuarioResponsableId,
    required this.ruc,
    required this.contactoId,
    required this.asunto,
    required this.comentario,
    required this.userEmail,
    required this.emailFrom,
    this.oportunidadId = '0',
    this.recipients = const [],
    this.files = const [],
    this.oportunidadEntries = const [],
  });

  Map<String, dynamic> toFormData() {
    final formData = <String, dynamic>{
      'ACTI_ID_USUARIO_RESPONSABLE': usuarioResponsableId,
      'ACTI_RUC': ruc,
      'ACTI_ID_OPORTUNIDAD': oportunidadId,
      'ACTI_ID_CONTACTO': contactoId,
      'ACTI_COMENTARIO': comentario,
      'EMLS_ASUNTO': asunto,
      'EMLS_EMAIL_FROM': emailFrom,
      'ACTIVIDADES_CONTACTO[0][ACNT_ID_CONTACTO]': contactoId,
    };

    for (int i = 0; i < recipients.length; i++) {
      formData.addAll(recipients[i].toFormData(i));
    }

    for (int i = 0; i < oportunidadEntries.length; i++) {
      final entry = oportunidadEntries[i];
      formData['ACTI_OPORTUNIDAD[$i][ACTI_ID_OPORTUNIDAD]'] =
          entry['ACTI_ID_OPORTUNIDAD'];
      formData['ACTI_OPORTUNIDAD[$i][ACTI_COMENTARIO]'] =
          entry['ACTI_COMENTARIO'];
    }

    print('========== EMAIL REQUEST ==========');
    formData.forEach((key, value) {
      print('  $key = $value');
    });

    return formData;
  }
}

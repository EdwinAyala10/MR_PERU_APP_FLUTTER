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
      // Backend espera ACNT_ID_CONTACTO (no ACTI_ID_CONTACTO)
      'ACTIVIDADES_CONTACTO[0][ACNT_ID_CONTACTO]': contactoId,
    };

    for (int i = 0; i < recipients.length; i++) {
      formData.addAll(recipients[i].toFormData(i));
    }

    if (files.isNotEmpty) {
      formData['files'] = files;
    }

    return formData;
  }
}

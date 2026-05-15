class EmailRecipient {
  final String contactId;
  final String email;
  final String type;
  final String isSystemEmail;

  const EmailRecipient({
    required this.contactId,
    required this.email,
    required this.type,
    this.isSystemEmail = 'SI',
  });

  Map<String, String> toFormData(int index) {
    return {
      'EMAIL_TO[$index][EMLT_ID_CONTACTO]': contactId,
      'EMAIL_TO[$index][EMLT_EMAIL_TO]': email,
      'EMAIL_TO[$index][EMLT_ID_TIPO]': type,
      'EMAIL_TO[$index][EMLT_CORREO_DE_SISTEMA]': isSystemEmail,
    };
  }
}

class EmailRecipientType {
  static const String to = '01';
  static const String cc = '02';
  static const String cco = '03';
}

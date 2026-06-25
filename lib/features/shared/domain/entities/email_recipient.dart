class EmailRecipient {
  final String contactId;
  final String name;
  final String email;
  final String type;
  final String isSystemEmail;

  const EmailRecipient({
    required this.contactId,
    required this.name,
    required this.email,
    required this.type,
    this.isSystemEmail = 'SI',
  });

  Map<String, String> toFormData(int index) {
    // Backend espera EMAIL_TO (no EMAIL_RECIPIENTS)
    // Los índices empiezan en 1 (no en 0)
    final idx = index + 1;
    return {
      'EMAIL_TO[$idx][name]': name,
      'EMAIL_TO[$idx][address]': email,
      'EMAIL_TO[$idx][EMLT_ID_TIPO]': type,
    };
  }
}

class EmailRecipientType {
  static const String to = '01';
  static const String cc = '02';
  static const String cco = '03';
}

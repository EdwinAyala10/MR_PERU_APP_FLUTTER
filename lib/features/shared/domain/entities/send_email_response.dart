class SendEmailResponse {
  final bool success;
  final String message;
  final dynamic data;

  const SendEmailResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

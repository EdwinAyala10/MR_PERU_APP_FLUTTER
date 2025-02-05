class CreateUpdateEventResponse {
  bool response;
  String message;
  String? id;

CreateUpdateEventResponse({
    required this.response,
    required this.message,
    this.id
  });
}
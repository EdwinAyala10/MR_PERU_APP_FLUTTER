class CreateUpdateContactResponse {
  bool response;
  String message;
  String? id;

CreateUpdateContactResponse({
    required this.response,
    required this.message,
    this.id
  });
}
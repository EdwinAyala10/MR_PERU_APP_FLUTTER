class CreateUpdateActivityResponse {
  bool response;
  String message;
  String? id;

CreateUpdateActivityResponse({
    required this.response,
    required this.message,
    this.id
  });
}
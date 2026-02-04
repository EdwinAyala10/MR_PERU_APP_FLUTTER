class UserMaster {
  final String id;
  final String code;
  final String name;
  final String type;
  final String? email;
  final String? abbrt;

  UserMaster({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.email,
    this.abbrt,
  });
}




class User {

  final String id;
  final String code;
  final String email;
  final String name;
  final String type;
  final List<String> roles;
  final String token;

  User({
    required this.id,
    required this.code,
    required this.email,
    required this.name,
    required this.type,
    required this.roles,
    required this.token
  });

  bool get isAdmin {
    return roles.contains('admin');
  }

}




class User {

  final String id;
  final String code;
  final String name;
  final String type;
  final List<String> roles;
  final String token;
  final String email;

  User({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.token,
    required this.roles,
    required this.email,
  });

  bool get isAdmin {
    return roles.contains('admin');
  }

}




import 'package:crm_app/features/auth/domain/domain.dart';

class User {

  final String id;
  final String code;
  final String name;
  final String type;
  //final List<String> roles;
  final List<Rol>? roles; 
  final String token;
  final String email;

  User({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.token,
    this.roles,
    required this.email,
  });

  /*bool get isAdmin {
    return roles.contains('admin');
  }*/

   bool get isAdmin {
    return roles!.any((rol) => rol.code == '01');
   }


}

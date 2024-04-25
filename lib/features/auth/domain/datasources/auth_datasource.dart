import '../entities/user.dart';

abstract class AuthDataSource {

  Future<User> login( String email, String password );
  Future<User> checkAuthStatus( String token );

  Future<bool> sendTokenDevice( String token, String tokenDevice, String userId );

}
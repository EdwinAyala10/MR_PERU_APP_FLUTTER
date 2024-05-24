import '../domain.dart';

abstract class UsersRepository {
  Future<List<UserMaster>> searchUsers(String query);
}


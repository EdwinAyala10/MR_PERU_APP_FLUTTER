import '../domain.dart';

abstract class UsersDatasource {

  Future<List<UserMaster>> searchUsers(String query);
}


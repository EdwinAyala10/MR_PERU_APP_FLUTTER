import 'package:crm_app/features/users/domain/domain.dart';

abstract class UsersRepository {
  Future<List<UserMaster>> searchUsers(String query);
}


import 'package:crm_app/features/users/domain/domain.dart';

abstract class UsersDatasource {

  Future<List<UserMaster>> searchUsers(String query);
}


import 'package:crm_app/features/users/domain/domain.dart';

class UsersRepositoryImpl extends UsersRepository {

  final UsersDatasource datasource;

  UsersRepositoryImpl(this.datasource);

  @override
  Future<List<UserMaster>> searchUsers(String query) {
    return datasource.searchUsers(query);
  }
}

  
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/users/domain/domain.dart';

import '../mappers/user_master_mapper.dart';

class UsersDatasourceImpl extends UsersDatasource {
  late final Dio dio;
  final String accessToken;

  UsersDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));
  
  @override
  Future<List<UserMaster>> searchUsers(String query) async {

    final data = {
      "SEARCH": query,
    };

    final response =
        await dio.get('/user/listar-usuarios-by-tipo', data: data);

    final List<UserMaster> users = [];
    for (final user in response.data['data'] ?? []) {
      users.add(UserMasterMapper.jsonToEntity(user));
    }

    return users;
  }
}

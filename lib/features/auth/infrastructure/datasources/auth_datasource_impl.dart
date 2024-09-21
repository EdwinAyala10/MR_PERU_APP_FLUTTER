import 'dart:developer';

import '../../../../config/config.dart';
import '../../domain/domain.dart';
import '../infrastructure.dart';
import 'package:dio/dio.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
  ));

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final response = await dio.post('/validate_token',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError('Token incorrecto');
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> login(String email, String password) async {
    log(dio.options.baseUrl);
    try {
      final response = await dio.post('/login_crm', data: {'email': email, 'password': password});
      log(response.realUri.path);
      final user = UserMapper.userJsonToEntity(response.data);

      return user;
    } on DioException catch (e) {
            log('mesvsdvsdvsssage');
      log(e.toString());
      if (e.response?.statusCode == 401) {
        throw CustomError(
            e.response?.data['message'] ?? 'Credenciales incorrectas');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception();
    } catch (e) {
      log('mesvsdvsdvsssage');
      log(e.toString());
      throw Exception();
    }
  }

  @override
  Future<bool> sendTokenDevice(
      String token, String tokenDevice, String userId) async {
    try {
      final response = await dio.post('/user/update-token-id-user',
          data: {'ID_USUARIO': userId, 'TOKEN_ID': tokenDevice},
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final status = response.data['status'];

      return status;
    } catch (e) {
      return false;
    }
  }
}

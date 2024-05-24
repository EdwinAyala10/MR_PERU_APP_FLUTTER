import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import '../../infrastructure/datasources/users_datasource_impl.dart';
import '../../infrastructure/repositories/users_repository_impl.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final usersRepository = UsersRepositoryImpl(
    UsersDatasourceImpl(accessToken: accessToken )
  );

  return usersRepository;
});


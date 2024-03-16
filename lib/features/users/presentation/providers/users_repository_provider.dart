import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:crm_app/features/users/infrastructure/datasources/users_datasource_impl.dart';
import 'package:crm_app/features/users/infrastructure/repositories/users_repository_impl.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final usersRepository = UsersRepositoryImpl(
    UsersDatasourceImpl(accessToken: accessToken )
  );

  return usersRepository;
});


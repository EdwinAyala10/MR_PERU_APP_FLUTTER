import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import '../../infrastructure/datasources/contacts_datasource_impl.dart';
import '../../infrastructure/repositories/contacts_repository_impl.dart';


final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final contactssRepository = ContactsRepositoryImpl(
    ContactsDatasourceImpl(accessToken: accessToken )
  );

  return contactssRepository;
});


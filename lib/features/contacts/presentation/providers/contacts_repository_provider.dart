import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/infrastructure/datasources/contacts_datasource_impl.dart';
import 'package:crm_app/features/contacts/infrastructure/repositories/contacts_repository_impl.dart';


final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final contactssRepository = ContactsRepositoryImpl(
    ContactsDatasourceImpl(accessToken: accessToken )
  );

  return contactssRepository;
});


import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/documents/domain/repositories/documents_repository.dart';
import 'package:crm_app/features/documents/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final documentsRepository = DocumentsRepositoryImpl(
    DocumentsDatasourceImpl(accessToken: accessToken )
  );

  return documentsRepository;
});


import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/opportunities/domain/repositories/doc_opportunitie_repository.dart';
import 'package:crm_app/features/opportunities/infrastructure/datasources/doc_opportunitie_datasource_impl.dart';
import 'package:crm_app/features/opportunities/infrastructure/repositories/doc_opportunitie_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final docOpportunitieRepositoryProvider = Provider<DocOpportunitieRepository>(
  (ref) {
    final accessToken = ref.watch(authProvider).user?.token ?? '';

    final documentsRepository = DocOpportunitieRepositoryImpl(
      DocOpportunitieDatasourceImpl(accessToken: accessToken),
    );
    return documentsRepository;
  },
);

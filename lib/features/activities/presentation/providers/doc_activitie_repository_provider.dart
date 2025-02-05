import 'package:crm_app/features/activities/domain/repositories/doc_activitie_repository.dart';
import 'package:crm_app/features/activities/infrastructure/datasources/doc_activitie_datasource_impl.dart';
import 'package:crm_app/features/activities/infrastructure/repositories/doc_activitie_repository_impl.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final docActivitieRepositoryProvider = Provider<DocActivitieRepository>(
  (ref) {
    final accessToken = ref.watch(authProvider).user?.token ?? '';

    final documentsRepository = DocActivitieRepositoryImpl(
      DocActivitieDatasourceImpl(accessToken: accessToken),
    );
    return documentsRepository;
  },
);

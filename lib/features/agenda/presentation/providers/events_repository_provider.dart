import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import '../../infrastructure/datasources/events_datasource_impl.dart';
import '../../infrastructure/repositories/events_repository_impl.dart';


final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final eventsRepository = EventsRepositoryImpl(
    EventsDatasourceImpl(accessToken: accessToken )
  );

  return eventsRepository;
});


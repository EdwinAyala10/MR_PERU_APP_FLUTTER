import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/agenda/infrastructure/datasources/events_datasource_impl.dart';
import 'package:crm_app/features/agenda/infrastructure/repositories/events_repository_impl.dart';


final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  
  final eventsRepository = EventsRepositoryImpl(
    EventsDatasourceImpl(accessToken: accessToken )
  );

  return eventsRepository;
});


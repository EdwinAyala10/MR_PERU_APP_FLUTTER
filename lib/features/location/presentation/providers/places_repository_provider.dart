import '../../domain/domain.dart';
import '../../infrastructure/datasources/place_datasource_impl.dart';
import '../../infrastructure/repositories/place_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  
  final placesRepository = PlacesRepositoryImpl(
    PlacesDatasourceImpl()
  );

  return placesRepository;
});


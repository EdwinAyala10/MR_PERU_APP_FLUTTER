import 'dart:async';

import '../../domain/models/places_models.dart';
import 'location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/infrastructure/services/key_value_storage_service.dart';
import '../../../shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final searchMapProvider = StateNotifierProvider<SearchMapNotifier, SearchMapState>((ref) {
  //final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return SearchMapNotifier(
      //authRepository: authRepository,
      keyValueStorageService: keyValueStorageService);
});

class SearchMapNotifier extends StateNotifier<SearchMapState> {
  //final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  StreamSubscription<Position>? positionStream;
  GoogleMapController? _mapController;
  LatLng? mapCenter;
  StreamSubscription<LocationState>? locationStateSubscription;
  //TrafficService trafficService;

  SearchMapNotifier({
    //required this.authRepository,
    required this.keyValueStorageService,
  }) : super(const SearchMapState()) {

  }

  
}

class SearchMapState {
  
  final bool displayManualMarker;
  final List<Feature> places;
  final List<Feature> history;

  const SearchMapState({
    this.displayManualMarker = false,
    this.places = const [],
    this.history = const [],
  });

  SearchMapState copyWith({
    bool? displayManualMarker,
    List<Feature>? places,
    List<Feature>? history
  }) 
  => SearchMapState(
    displayManualMarker: displayManualMarker ?? this.displayManualMarker,
    places: places ?? this.places,
    history: history ?? this.history,
  );

}

import 'dart:async';

import 'package:crm_app/features/location/presentation/providers/location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  //final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return MapNotifier(
      //authRepository: authRepository,
      keyValueStorageService: keyValueStorageService);
});

class MapNotifier extends StateNotifier<MapState> {
  //final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  StreamSubscription<Position>? positionStream;
  GoogleMapController? _mapController;
  LatLng? mapCenter;
  StreamSubscription<LocationState>? locationStateSubscription;

  MapNotifier({
    //required this.authRepository,
    required this.keyValueStorageService,
  }) : super(const MapState()) {}

  void onInitMap(GoogleMapController controller) {
    _mapController = controller;
    state = state.copyWith(isMapInitialized: true);
  }
}

class MapState {
  final bool isMapInitialized;

  const MapState({
    this.isMapInitialized = false,
  });

  MapState copyWith({
    bool? isMapInitialized,
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
      );
}

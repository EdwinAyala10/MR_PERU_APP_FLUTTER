import 'dart:async';

import '../../domain/domain.dart';
import 'location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/infrastructure/services/key_value_storage_service.dart';
import '../../../shared/infrastructure/services/key_value_storage_service_impl.dart';
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
  StreamSubscription<LocationState>? locationStateSubscription;

  MapNotifier({
    //required this.authRepository,
    required this.keyValueStorageService,
  }) : super(MapState());

  void onInitMap(GoogleMapController controller) {
    _mapController = controller;
    state = state.copyWith(isMapInitialized: true);
  }

  void onChangeMapCenter(LatLng latLng) {
    state = state.copyWith(
      mapCenter: latLng,
      selectedPlace: null
    );
  }

  void onChangeSelectedPlaceCenter(Place place) {
    state = state.copyWith(
      selectedPlace: place,
    );
  }

  void moveCamera(LatLng newLocation) {
    final cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController?.animateCamera(cameraUpdate);
  }
}

class MapState {
  final bool isMapInitialized;
  final LatLng? mapCenter;
  final Place? selectedPlace;

  MapState({this.isMapInitialized = false, this.mapCenter, this.selectedPlace});

  MapState copyWith({
    bool? isMapInitialized,
    LatLng? mapCenter,
    Place? selectedPlace
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        mapCenter: mapCenter ?? this.mapCenter,
        selectedPlace: selectedPlace ?? this.selectedPlace,
      );
}

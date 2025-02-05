import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/infrastructure/services/key_value_storage_service.dart';
import '../../../shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  //final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return LocationNotifier(
      //authRepository: authRepository,
      keyValueStorageService: keyValueStorageService);
});

class LocationNotifier extends StateNotifier<LocationState> {
  //final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  StreamSubscription<Position>? positionStream;

  LocationNotifier({
    //required this.authRepository,
    required this.keyValueStorageService,
  }) : super(const LocationState());

  Future getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    state = state.copyWith(
        lastKnownLocation: LatLng(position.latitude, position.longitude));
  }

  void setOnLocationAddressDiff() {
    state = state.copyWith(selectedLocationAddressDiff: true);
  }

  void setCoorsLocationAddressDiff(double lat, double lng) {
    state = state.copyWith(locationAddressDiff: LatLng(lat, lng));
  }

  void setOffLocationAddressDiff() {
    state = state.copyWith(
        selectedLocationAddressDiff: false,
        distanceLocationAddressDiff: 0,
        locationAddressDiff: null);
  }

  void startFollowingUser() {
    state = state.copyWith(followingUser: true);

    positionStream = Geolocator.getPositionStream().listen((event) {
      final position = event;

      bool? allowSaveDiff;

      if (state.selectedLocationAddressDiff) {
        double radio = 100; // en metros
        bool dentroDelRadio = dentroDeRadio(
            position.latitude,
            position.longitude,
            state.locationAddressDiff?.latitude ?? 0,
            state.locationAddressDiff?.longitude ?? 0,
            radio);

        //if (dentroDelRadio) {
        //print('La coordenada está dentro del radio de $radio metros.');
        allowSaveDiff = dentroDelRadio;
        //} else {
        //print('La coordenada está fuera del radio de $radio metros.');
        //allowSaveDiff = false;
        //}
      }

      state = state.copyWith(
          lastKnownLocation: LatLng(position.latitude, position.longitude),
          allowSave: allowSaveDiff);
    });
  }

  double distanciaCoordenadas(
      double lat1, double lon1, double lat2, double lon2) {
    const radioTierra = 6371000; // Radio de la Tierra en metros
    var dLat = _gradosARadianes(lat2 - lat1);
    var dLon = _gradosARadianes(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_gradosARadianes(lat1)) *
            cos(_gradosARadianes(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * asin(sqrt(a));
    var distancia = radioTierra * c;
    return distancia;
    //var distanciaMetros = radioTierra * c;
    //var distanciaKilometros = distanciaMetros / 1000; // Convertir metros a kilómetros
    //return distanciaKilometros;
  }

  double _gradosARadianes(double grados) {
    return grados * (pi / 180);
  }

  bool dentroDeRadio(
      double lat1, double lon1, double lat2, double lon2, double radio) {
    double distancia = distanciaCoordenadas(lat1, lon1, lat2, lon2);

    state = state.copyWith(distanceLocationAddressDiff: distancia);

    return distancia <= radio;
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    state = state.copyWith(followingUser: false);
  }

  Future<LatLng> currentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 60));

      state = state.copyWith(
          lastKnownLocation: LatLng(position.latitude, position.longitude));

      return state.lastKnownLocation!;
    } catch (e) {
      state =
          state.copyWith(lastKnownLocation: const LatLng(-12.04318, -77.02824));
      return state.lastKnownLocation!;
    }
  }

  /*
  @override
  Future<void> close() {
    stopFollowingUser();
    return super.close();
  }*/
}

class LocationState {
  final bool followingUser;
  final LatLng? lastKnownLocation;
  final List<LatLng> myLocationHistory;
  final LatLng? locationAddressDiff;
  final bool selectedLocationAddressDiff;
  final double distanceLocationAddressDiff;
  final bool allowSave;

  const LocationState({
    this.followingUser = false,
    this.lastKnownLocation,
    myLocationHistory,
    this.locationAddressDiff,
    this.selectedLocationAddressDiff = false,
    this.distanceLocationAddressDiff = 0,
    this.allowSave = true,
  }) : myLocationHistory = myLocationHistory ?? const [];

  LocationState copyWith({
    bool? followingUser,
    LatLng? lastKnownLocation,
    List<LatLng>? myLocationHistory,
    bool? selectedLocationAddressDiff,
    LatLng? locationAddressDiff,
    double? distanceLocationAddressDiff,
    bool? allowSave,
  }) =>
      LocationState(
        followingUser: followingUser ?? this.followingUser,
        lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
        myLocationHistory: myLocationHistory ?? this.myLocationHistory,
        locationAddressDiff: locationAddressDiff ?? this.locationAddressDiff,
        selectedLocationAddressDiff:
            selectedLocationAddressDiff ?? this.selectedLocationAddressDiff,
        distanceLocationAddressDiff:
            distanceLocationAddressDiff ?? this.distanceLocationAddressDiff,
        allowSave: allowSave ?? this.allowSave,
      );

  List<Object?> get props => [
        followingUser,
        lastKnownLocation,
        myLocationHistory,
        locationAddressDiff,
        selectedLocationAddressDiff,
        distanceLocationAddressDiff,
        allowSave
      ];
}

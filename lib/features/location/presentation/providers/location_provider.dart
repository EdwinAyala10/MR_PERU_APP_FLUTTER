import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
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
  }) : super(const LocationState()) {
  }

  Future getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    state = state.copyWith(
        lastKnownLocation: LatLng(position.latitude, position.longitude));
  }

  void startFollowingUser() {
    state = state.copyWith(followingUser: true);

    positionStream = Geolocator.getPositionStream().listen((event) {
      final position = event;

      state = state.copyWith(
        lastKnownLocation: LatLng(position.latitude, position.longitude)
      );
    });
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    state = state.copyWith(followingUser: false);
    print('stopFollowingUser');
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

  const LocationState(
      {this.followingUser = false, this.lastKnownLocation, myLocationHistory})
      : myLocationHistory = myLocationHistory ?? const [];

  LocationState copyWith({
    bool? followingUser,
    LatLng? lastKnownLocation,
    List<LatLng>? myLocationHistory,
  }) =>
      LocationState(
        followingUser: followingUser ?? this.followingUser,
        lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
        myLocationHistory: myLocationHistory ?? this.myLocationHistory,
      );

  @override
  List<Object?> get props =>
      [followingUser, lastKnownLocation, myLocationHistory];
}

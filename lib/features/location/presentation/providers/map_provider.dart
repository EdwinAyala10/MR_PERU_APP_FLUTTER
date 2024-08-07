import 'dart:async';
import 'dart:math';

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/location/presentation/widgets/widgets_to_marker.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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

  void setLocation(LatLng location) {
    state = state.copyWith(
      mapCenter: location,
      locationCurrent: location
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radio de la Tierra en kilómetros
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c; // Distancia en kilómetros
    return distance;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }


  Future<List<CompanyLocalRoutePlanner>> sortLocalesByDistance(LatLng position, List<CompanyLocalRoutePlanner> locales) async {
    locales.sort((a, b) {
      final distanceA = _calculateDistance(
        position.latitude, position.longitude, double.parse(a.localCoordenadasLatitud), double.parse(a.localCoordenadasLongitud));
      final distanceB = _calculateDistance(
        position.latitude, position.longitude, double.parse(b.localCoordenadasLatitud), double.parse(b.localCoordenadasLongitud));
      return distanceA.compareTo(distanceB);
    });

    return locales;
  }



  void addMarkersAndLocation(List<CompanyLocalRoutePlanner> locales, LatLng location) async {

    final currentMarkers = Map<String, Marker>.from( {} );
    final currentPolylines = Map<String, Polyline>.from( {} );
    
    PolylinePoints polylinePoints = PolylinePoints();

    // LOCATION
    final locationMaker = await getLocationCustomMarker();

    final startMarker = Marker(
      //anchor: const Offset(0.1, 1),
      markerId: const MarkerId('location'),
      position: location,
      icon: locationMaker,
      // infoWindow: InfoWindow(
      //   title: 'Inicio',
      //   snippet: 'Kms: $kms, duration: $tripDuration',
      // )
    );

    currentMarkers['location'] = startMarker;

    //List<CompanyLocalRoutePlanner> localesOrderMarkers = await _sortLocalesByDistance(position, locales);

    //MARKERS
    for (var i = 0; i < locales.length; i++) {
        var number = i + 1;
        var companyLocal = locales[i];
        List<LatLng> polylineCoordinates = [];

        var position = LatLng(double.parse(companyLocal.localCoordenadasLatitud), double.parse(companyLocal.localCoordenadasLongitud));
      
        final endMaker = await getCustomMarker(number);

        final endMarker = Marker(
          //anchor: const Offset(0.1, 1),
          markerId: MarkerId(number.toString()),
          position: position,
          icon: endMaker,
          // infoWindow: InfoWindow(
          //   title: 'Inicio',
          //   snippet: 'Kms: $kms, duration: $tripDuration',
          // )
        );

        currentMarkers[number.toString()] = endMarker;  

        
        LatLng positionDestination = position;
        LatLng positionOrigin = location;

        if (i == 0) {
          positionOrigin = location;
          positionDestination = position;
        } else {
          var positionOrig = LatLng(double.parse(locales[i-1].localCoordenadasLatitud), double.parse(locales[i-1].localCoordenadasLongitud));
          var positionDest = position;

          positionDestination = positionDest;
          positionOrigin = positionOrig;
        }


        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: Environment.apiKeyGoogleMaps,
          request: PolylineRequest(
            origin: PointLatLng(positionOrigin.latitude, positionOrigin.longitude),
            destination: PointLatLng(positionDestination.latitude, positionDestination.longitude),
            mode: TravelMode.driving,
            //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
          ),
        );

        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }

        PolylineId id = PolylineId("poly_${number}");
        Polyline polyline = Polyline(
            polylineId: id, 
            points: polylineCoordinates,
            color: primaryColor,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          );
        currentPolylines[id.toString()] = polyline;
    }

    state = state.copyWith(
      markers: currentMarkers,
      polylines: currentPolylines,
    );
  }

  void addMarkers(List<CompanyLocalRoutePlanner> locales) async {
    
    final currentMarkers = Map<String, Marker>.from( state.markers );

    for (var i = 0; i < locales.length; i++) {
        var number = i + 1;
        var companyLocal = locales[i];

        var location = LatLng(double.parse(companyLocal.localCoordenadasLatitud), double.parse(companyLocal.localCoordenadasLongitud));
      
        final startMaker = await getCustomMarker(number);

        final startMarker = Marker(
          //anchor: const Offset(0.1, 1),
          markerId: MarkerId(number.toString()),
          position: location,
          icon: startMaker,
          // infoWindow: InfoWindow(
          //   title: 'Inicio',
          //   snippet: 'Kms: $kms, duration: $tripDuration',
          // )
        );

        currentMarkers[number.toString()] = startMarker;
    }

    state = state.copyWith(
      markers: currentMarkers
    );
  }

  void addMarker(LatLng position, String id, BitmapDescriptor descriptor, int number) async {
   
    final startMaker = await getCustomMarker(number);

    final startMarker = Marker(
      //anchor: const Offset(0.1, 1),
      markerId: MarkerId(id),
      position: position,
      icon: startMaker,
      // infoWindow: InfoWindow(
      //   title: 'Inicio',
      //   snippet: 'Kms: $kms, duration: $tripDuration',
      // )
    );

    final currentMarkers = Map<String, Marker>.from( state.markers );
    currentMarkers[id] = startMarker;

    state = state.copyWith(
      markers: currentMarkers
    );
  }

  void addMarkerLocation(LatLng position) async {
    final startMaker = await getLocationCustomMarker();

    final startMarker = Marker(
      //anchor: const Offset(0.1, 1),
      markerId: const MarkerId('location'),
      position: position,
      icon: startMaker,
      // infoWindow: InfoWindow(
      //   title: 'Inicio',
      //   snippet: 'Kms: $kms, duration: $tripDuration',
      // )
    );

    final currentMarkers = Map<String, Marker>.from( state.markers );
    currentMarkers['location'] = startMarker;

    state = state.copyWith(
      markers: currentMarkers
    );
  }
}


class MapState {
  final bool isMapInitialized;
  final LatLng? mapCenter;
  final LatLng? locationCurrent;
  final Place? selectedPlace;
  final Map<String, Marker> markers;
  final Map<String, Polyline> polylines;

  MapState({
    this.isMapInitialized = false, 
    this.mapCenter, 
    this.locationCurrent, 
    this.selectedPlace,
    this.markers = const {},
    this.polylines = const {}
  });

  MapState copyWith({
    bool? isMapInitialized,
    LatLng? mapCenter,
    LatLng? locationCurrent,
    Place? selectedPlace,
    Map<String, Marker>? markers,
    Map<String, Polyline>? polylines,
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        mapCenter: mapCenter ?? this.mapCenter,
        locationCurrent: locationCurrent ?? this.locationCurrent,
        selectedPlace: selectedPlace ?? this.selectedPlace,
        markers: markers ?? this.markers,
        polylines: polylines ?? this.polylines,
      );
}

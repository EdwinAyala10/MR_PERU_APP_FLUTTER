import 'package:crm_app/features/location/presentation/providers/location_provider.dart';
import 'package:crm_app/features/location/presentation/providers/providers.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDayScreen extends ConsumerStatefulWidget {
  @override
  _RouteDayScreenState createState() => _RouteDayScreenState();
}

class _RouteDayScreenState extends ConsumerState<RouteDayScreen> {
  /*GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> routeCoordinates = [];
  double totalDistance = 0.0;
  double totalTime = 0.0;

  final List<LatLng> storeLocations = [
    const LatLng(-12.0453, -77.0311),
    const LatLng(-12.0353, -77.0231),
    const LatLng(-12.0253, -77.0131),
  ];*/

  late GoogleMapController mapController;
  double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  double _destLatitude = 6.849660, _destLongitude = 3.648190;

  //Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyAjpuHF1NQQigzXXmP7cGV6bUzTO9tQ0nI";


  @override
  void initState() {
    super.initState();
    //_getCurrentLocation();
    //_addStoreMarkers();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //final locationNotifier = ref.read(locationProvider.notifier);
      //locationNotifier.startFollowingUser();

      //_getCurrentLocation();

      //_getLocalesMarkers();

      _getLocationAndMarkers();
    });




    /// origin marker
    /*_addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    */

    //_getPolyline();
  }

   /*_addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }*/

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPiKey,
      request: PolylineRequest(
        origin: PointLatLng(_originLatitude, _originLongitude),
        destination: PointLatLng(_destLatitude, _destLongitude),
        mode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  /*void _getCurrentLocation() async {
    setState(() {

      _markers.add(
        const Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(-12.0464, -77.0428),
        ),
      );
      
      /*Position position = Position(
        longitude: -12.0464,
        latitude: -77.0428,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );*/
      //_calculateRoutes(position);
    });
  }*/

  /*void _addStoreMarkers() {
    for (int i = 0; i < storeLocations.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('store$i'),
          position: storeLocations[i],
        ),
      );
    }
  }*/

  /*  LatLng currentLocation = LatLng(origin.latitude, origin.longitude);

    for (LatLng storeLocation in storeLocations) {
      PolylinePoints polylinePoints = PolylinePoints();

      print('currentLocation.latitude: ${currentLocation.latitude}');
      print('currentLocation.longitude: ${currentLocation.longitude}');

      print('storeLocation.latitude: ${storeLocation.latitude}');
      print('storeLocation.longitude: ${storeLocation.longitude}');

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyAjpuHF1NQQigzXXmP7cGV6bUzTO9tQ0nI',
        request: PolylineRequest(
          origin: PointLatLng(currentLocation.latitude, currentLocation.longitude),
          destination: PointLatLng(storeLocation.latitude, storeLocation.longitude),
          mode: TravelMode.driving,
        ),
      );

      print('RESULT: ${result}');
      print('RESULT POINTS: ${result.points}');

      if (result.points.isNotEmpty) {
        List<LatLng> route = [];
        result.points.forEach((PointLatLng point) {
          route.add(LatLng(point.latitude, point.longitude));
        });
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId(storeLocation.toString()),
              points: route,
              color: Colors.blue,
              width: 5,
            ),
          );
          //totalDistance += _calculateDistance(route);
          totalTime = totalDistance / 50; // Assuming average speed of 50 km/h
        });

        // Update current location for next leg of the journey
        currentLocation = storeLocation;
      }
    }
  }*/

  /*double _calculateDistance(List<LatLng> points) {
    double distance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return distance / 1000; // Convert to km
  }*/

  void _getLocationAndMarkers() async {
    final mapState = ref.watch(mapProvider.notifier);
    LatLng? location = ref.read(mapProvider).locationCurrent;
    
    final List<CompanyLocalRoutePlanner> listSelectedItems = ref.watch(routePlannerProvider).selectedItems;
    ref.watch(mapProvider.notifier).addMarkersAndLocation(listSelectedItems, location!);

  }

  void _getLocalesMarkers() async {
    final List<CompanyLocalRoutePlanner> listSelectedItems = ref.watch(routePlannerProvider).selectedItems;

    ref.watch(mapProvider.notifier).addMarkers(listSelectedItems);
  }

  void _getCurrentLocation() async {
    /*Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
        ),
      );
      _calculateRoutes(position);
    });*/

    //final locationState = ref.watch(locationProvider);
    final mapState = ref.watch(mapProvider.notifier);
    LatLng? location = ref.read(mapProvider).locationCurrent;

    //print('LAT LNG');
    //print(lastKnownLocation);

    if (location != null) {
      /*_addMarker(LatLng(lastKnownLocation.latitude, lastKnownLocation.longitude), "location",
          BitmapDescriptor.defaultMarkerWithHue(90));*/

      ref.watch(mapProvider.notifier).addMarkerLocation(
        LatLng(location.latitude, location.longitude), 
      );
    }



  }

  @override
  Widget build(BuildContext context) {

    final locationState = ref.watch(locationProvider);
    final mapState = ref.watch(mapProvider.notifier);
    final List<CompanyLocalRoutePlanner> listSelectedItems = ref.watch(routePlannerProvider).selectedItems;
    LatLng lastKnownLocation = locationState.lastKnownLocation ?? LatLng(-12.046736441022516, -77.0440978949104);
    final markers = ref.watch(mapProvider).markers;
    final polylines = ref.watch(mapProvider).polylines;
    
    CameraPosition initialCameraPosition =
        CameraPosition(target: lastKnownLocation, zoom: 11.5);

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: GoogleMap(
                  
                  /*onMapCreated: (controller) => mapController = controller,
                  myLocationEnabled: true,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-12.0464, -77.0428),
                    zoom: 12,
                  ),
                  markers: _markers,
                  polylines: _polylines,*/
                  /*initialCameraPosition: CameraPosition(
                      target: LatLng(_originLatitude, _originLongitude), zoom: 15),*/
                  initialCameraPosition: initialCameraPosition,
                  //myLocationEnabled: true,
                  compassEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  //onMapCreated: _onMapCreated,
                  onMapCreated: (controller) => mapState.onInitMap(controller),
                  
                  //markers: Set<Marker>.of(markers!.values),
                  //polylines: Set<Polyline>.of(polylines.values),
                  markers: markers.values.toSet(),
                  polylines: polylines.values.toSet(),
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              /*Positioned(
                top: 40,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    // Aquí puedes agregar la lógica para ordenar
                  },
                  child: const Icon(Icons.sort),
                ),
              ),*/
              /*Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Distancia Total: ${totalDistance.toStringAsFixed(2)} km'),
                      Text('Tiempo Estimado: ${totalTime.toStringAsFixed(2)} horas'),
                    ],
                  ),
                ),
              ),*/
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listSelectedItems.length,
              itemBuilder: (context, index) {

                var item = listSelectedItems[index];

                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.store, color: Colors.blue),
                      title: Text(
                        item.localNombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${item.razon}'
                      ),
                      trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                    const Divider(
                      color: Colors.blueGrey,
                      height: 1,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

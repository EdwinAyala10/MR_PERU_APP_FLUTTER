import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RouteDayScreen extends ConsumerStatefulWidget {
  @override
  _RouteDayScreenState createState() => _RouteDayScreenState();
}

class _RouteDayScreenState extends ConsumerState<RouteDayScreen> {
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> routeCoordinates = [];
  double totalDistance = 0.0;
  double totalTime = 0.0;

  final List<LatLng> storeLocations = [
    LatLng(-12.0453, -77.0311),
    LatLng(-12.0353, -77.0231),
    LatLng(-12.0253, -77.0131),
  ];


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addStoreMarkers();
  }

  void _getCurrentLocation() async {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(-12.0464, -77.0428),
        ),
      );
      Position position = Position(
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
      );
      _calculateRoutes(position);
    });
  }

  void _addStoreMarkers() {
    for (int i = 0; i < storeLocations.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('store$i'),
          position: storeLocations[i],
        ),
      );
    }
  }

  void _calculateRoutes(Position origin) async {
    LatLng currentLocation = LatLng(origin.latitude, origin.longitude);

    for (LatLng storeLocation in storeLocations) {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyAjpuHF1NQQigzXXmP7cGV6bUzTO9tQ0nI',
        request: PolylineRequest(
          origin: PointLatLng(currentLocation.latitude, currentLocation.longitude),
          destination: PointLatLng(storeLocation.latitude, storeLocation.longitude),
          mode: TravelMode.driving,
        ),
      );
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
          totalDistance += _calculateDistance(route);
          totalTime = totalDistance / 50; // Assuming average speed of 50 km/h
        });

        // Update current location for next leg of the journey
        currentLocation = storeLocation;
      }
    }
  }

  double _calculateDistance(List<LatLng> points) {
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
  }

  @override
  Widget build(BuildContext context) {

    final List<CompanyLocalRoutePlanner> listSelectedItems = ref.watch(routePlannerProvider).selectedItems;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: GoogleMap(
                  onMapCreated: (controller) => mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-12.0464, -77.0428),
                    zoom: 12,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    // Aquí puedes agregar la lógica para ordenar
                  },
                  child: Icon(Icons.sort),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
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
              ),
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
                      leading: Icon(Icons.store, color: Colors.blue),
                      title: Text(
                        '${item.localNombre}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${item.razon}'
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ),
                    Divider(
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

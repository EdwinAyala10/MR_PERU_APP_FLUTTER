import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDayScreen2 extends StatefulWidget {
  @override
  _RoutePlannerState createState() => _RoutePlannerState();
}

class _RoutePlannerState extends State<RouteDayScreen2> {
  GoogleMapController? mapController;
  final LatLng _initialPosition = LatLng(-12.046373, -77.042754); // Lima, Perú
  final List<LatLng> _markerPositions = [
    LatLng(-12.046373, -77.042754), // Lima
    LatLng(-12.056373, -77.052754), // Another point in Lima
    LatLng(-12.066373, -77.062754), // Another point in Lima
    LatLng(-12.076373, -77.072754), // Another point in Lima
  ];
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double _totalDistance = 0.0;
  int _totalTime = 0;

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _drawRoute();
  }

  void _addMarkers() {
    _markerPositions.asMap().forEach((index, position) {
      _markers.add(
        Marker(
          markerId: MarkerId(index.toString()),
          position: position,
        ),
      );
    });
  }

  void _drawRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];

    for (int i = 0; i < _markerPositions.length - 1; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyAjpuHF1NQQigzXXmP7cGV6bUzTO9tQ0nI',
        request: PolylineRequest(
          origin: PointLatLng(_markerPositions[i].latitude, _markerPositions[i].longitude),
          destination: PointLatLng(_markerPositions[i + 1].latitude, _markerPositions[i + 1].longitude), 
          mode:  TravelMode.driving),
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route$i'),
              points: polylineCoordinates,
              width: 5,
              color: Colors.blue,
            ),
          );

          _totalDistance += _calculateDistance(
            _markerPositions[i].latitude,
            _markerPositions[i].longitude,
            _markerPositions[i + 1].latitude,
            _markerPositions[i + 1].longitude,
          );

          _totalTime += result.totalDurationValue ?? 0;
        });
      }
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    double p = 0.017453292519943295;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Distance: ${_totalDistance.toStringAsFixed(2)} km'),
                  Text('Total Time: ${(_totalTime / 60).toStringAsFixed(2)} mins'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
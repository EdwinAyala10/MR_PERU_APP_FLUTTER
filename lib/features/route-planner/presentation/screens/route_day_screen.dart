import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/location/presentation/providers/providers.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/forms/event_planner_form_provider.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/shared/widgets/format_distance.dart';
import 'package:crm_app/features/shared/widgets/format_duration.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

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

  late List<ItemData> _items;

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

      //_getLocationAndMarkers();
    });

    _items = [];
    for (int i = 0; i < 500; ++i) {
      String label = "List item $i";
      if (i == 5) {
        label += ". This item has a long label and will be wrapped.";
      }
      _items.add(ItemData(label, ValueKey(i)));
    }


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
    PolylineId id = const PolylineId("poly");
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
    //final mapState = ref.watch(mapProvider.notifier);
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

  int _indexOfKey(Key key) {
    return _items.indexWhere((ItemData d) => d.key == key);
  }

  @override
  Widget build(BuildContext context) {

    final locationState = ref.watch(locationProvider);
    final mapState = ref.watch(mapProvider.notifier);
    final List<CompanyLocalRoutePlanner> listSelectedItems = ref.watch(routePlannerProvider).selectedItems;
    LatLng lastKnownLocation = locationState.lastKnownLocation ?? const LatLng(-12.046736441022516, -77.0440978949104);
    final markers = ref.watch(mapProvider).markers;
    final polylines = ref.watch(mapProvider).polylines;

    final int totalDistance = ref.watch(mapProvider).totalDistance;
    final int totalDuration = ref.watch(mapProvider).totalDuration;
    
    CameraPosition initialCameraPosition =
        CameraPosition(target: lastKnownLocation, zoom: 11.5);

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
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
              Positioned(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Ruta planificada', 
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('${listSelectedItems.length} Check-ins'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Distancia',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(formatDistanceV2(totalDistance)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Tiempo',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(formatDuration(totalDuration)),
                        ],
                      ),
                      //Text('Distancia Total: ${totalDistance.toStringAsFixed(2)} km'),
                      //Text('Tiempo Estimado: ${totalTime.toStringAsFixed(2)} horas'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          /*Expanded(
            child: ListView.builder(
              itemCount: listSelectedItems.length,
              itemBuilder: (context, index) {

                var item = listSelectedItems[index];

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        child: Text('${index + 1}'),
                      ),
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
          ),*/

          /*Expanded(
            child: ReorderableList(
              onReorder: (Key item, Key newPosition) {
                int draggingIndex = _indexOfKey(item);
                int newPositionIndex = _indexOfKey(newPosition);

                print('DAVID item: ${item}');
                print('DAVID newPosition: ${newPosition}');

                print('DAVID draggingIndex: ${draggingIndex}');
                print('DAVID newPositionIndex: ${newPositionIndex}');

                // Uncomment to allow only even target reorder possition
                // if (newPositionIndex % 2 == 1)
                //   return false;

                final draggedItem = _items[draggingIndex];
                setState(() {
                  debugPrint("Reordering $item -> $newPosition");
                  _items.removeAt(draggingIndex);
                  _items.insert(newPositionIndex, draggedItem);
                });
                return true;
              },
              onReorderDone: (Key item) {
                final draggedItem = _items[_indexOfKey(item)];
                debugPrint("Reordering finished for ${draggedItem.title}}");
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return ItemCustom(
                              data: _items[index],
                              isFirst: index == 0,
                              isLast: index == _items.length - 1,
                            );
                          },
                          childCount: _items.length,
                        ),
                      )),
                ],
              ),
            )
          )*/

          Expanded(
            child: ReorderableList(
              onReorder: (Key item, Key newPosition) {
                return ref.read(routePlannerProvider.notifier).onReorder(item, newPosition, listSelectedItems);
              },
              onReorderDone: (Key item) async {
                print('EJECUTA ON REORDER DONE');
                /*final draggedItem = _items[_indexOfKey(item)];
                debugPrint("Reordering finished for ${draggedItem.title}}");*/
                //ref.read(routePlannerProvider.notifier).onSetLocalesTmpInLocales();
                showLoadingMessage(context);

                LatLng location = await ref.watch(locationProvider.notifier).currentPosition();

                //List<CompanyLocalRoutePlanner> orderSelectedItems = await ref.read(mapProvider.notifier).sortLocalesByDistance(location, listSelectedItems);

                //await ref.read(routePlannerProvider.notifier).setSelectedItemsOrder(orderSelectedItems);
                await ref.read(routePlannerProvider.notifier).initialOrderkey();

                ref.read(mapProvider.notifier).setLocation(location);

                final List<CompanyLocalRoutePlanner> listSelectedItemsRenew = ref.watch(routePlannerProvider).selectedItems;

                ref.watch(mapProvider.notifier).addMarkersAndLocation(listSelectedItemsRenew, location);
                await ref.read(eventPlannerFormProvider.notifier).setLocalesArray(listSelectedItemsRenew);

                Navigator.pop(context);
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return ItemLocal(
                              data: listSelectedItems[index],
                              isFirst: index == 0,
                              isLast: index == listSelectedItems.length - 1,
                              index: index
                            );
                          },
                          childCount: listSelectedItems.length,
                        ),
                      )),
                ],
              ),
            )
          )

        ],
      ),
    );
  }
}


class ItemData {
  ItemData(this.title, this.key);

  final String title;

  // Each item in reorderable list needs stable and unique key
  final Key key;
}


class ItemCustom extends ConsumerWidget {
  const ItemCustom({
    Key? key,
    required this.data,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  final ItemData data;
  final bool isFirst;
  final bool isLast;

  Widget _buildChild(BuildContext context, ReorderableItemState state, WidgetRef ref) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      decoration = const BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 14.0),
                    child: Text(data.title,
                        style: Theme.of(context).textTheme.titleMedium),
                  )),
                  // Triggers the reordering
                  ReorderableListener(
                    child: Container(
                      padding: const EdgeInsets.only(right: 18.0, left: 18.0),
                      color: const Color(0x08000000),
                      child: const Center(
                        child: Icon(Icons.reorder, color: Color(0xFF888888)),
                      ),
                    ),
                    
                  ),
                ],
              ),
            ),
          )),
    );

    return content;
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return ReorderableItem(
        key: data.key, //
        childBuilder: (BuildContext context, ReorderableItemState state) {
          return _buildChild(context, state, ref);
        });
  }
}

class ItemLocal extends ConsumerWidget {
  const ItemLocal({
    Key? key,
    required this.data,
    required this.isFirst,
    required this.isLast,
    required this.index,
  }) : super(key: key);

  final CompanyLocalRoutePlanner data;
  final bool isFirst;
  final bool isLast;
  final int index;

  Widget _buildChild(BuildContext context, ReorderableItemState state, WidgetRef ref) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      decoration = const BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 14.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircleAvatar(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.localNombre,
                                    style: Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                ),
                                Text(data.razon ?? '',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.black87
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                ),
                                Text(data.localDireccion ?? '',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.black54,
                                      fontSize: 13
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                  ReorderableListener(
                    child: Container(
                      padding: const EdgeInsets.only(right: 18.0, left: 18.0),
                      color: const Color(0x08000000),
                      child: const Center(
                        child: Icon(Icons.reorder, color: Color(0xFF888888)),
                      ),
                    ),
                    /*canStart: () {
                      ref.read(routePlannerProvider.notifier).onLocalesTemp();
                      return true;
                    },*/
                  ),
                ],
              ),
            ),
          )),
    );

    return content;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableItem(
        key: data.key!, //
        childBuilder: (BuildContext context, ReorderableItemState state) {
          return _buildChild(context, state, ref);
        });
  }
}
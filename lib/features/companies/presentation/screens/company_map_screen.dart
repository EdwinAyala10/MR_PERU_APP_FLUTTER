import 'dart:async';
import 'dart:io';

import '../widgets/show_loading_message.dart';
import '../../../location/domain/domain.dart';
import '../../../location/presentation/delegates/search_places_delegate.dart';
import '../../../location/presentation/providers/location_provider.dart';
import '../../../location/presentation/providers/map_provider.dart';
import '../../../location/presentation/search/search_places_provider.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompanyMapScreen extends ConsumerWidget {
  final String rucId;
  final String identificator;

  const CompanyMapScreen(
      {super.key, required this.rucId, required this.identificator});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final companyCheckInState = ref.watch(companyCheckInProvider(rucId));

    return Scaffold(
      body: _CompanyMapView(),
    );
  }
}

class _CompanyMapView extends ConsumerStatefulWidget {
  const _CompanyMapView();

  @override
  _CompanyMapViewState createState() => _CompanyMapViewState();
}

class _CompanyMapViewState extends ConsumerState {
  late StreamSubscription<LocationState> _locationSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final locationNotifier = ref.read(locationProvider.notifier);
      locationNotifier.startFollowingUser();

      print('INICIO START FLLOWING');
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).stopFollowingUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final locationState = ref.watch(locationProvider);
    final mapState = ref.watch(mapProvider.notifier);
    LatLng lastKnownLocation = locationState.lastKnownLocation!;

    print('lastKnownLocation: ${lastKnownLocation.toString()}');

    CameraPosition initialCameraPosition =
        CameraPosition(target: lastKnownLocation, zoom: 15);

    return SingleChildScrollView(
      child: Stack(children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: Listener(
            child: GoogleMap(
                initialCameraPosition: initialCameraPosition,
                mapType: MapType.normal,
                /*compassEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,*/
                //polylines: polylines,
                //markers: markers,
                onMapCreated: (controller) => mapState.onInitMap(controller),
                onCameraMove: (position) =>
                    mapState.onChangeMapCenter(position.target)),
          ),
        ),

        //SEARCH
        FadeInDown(
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInLeft(
                    duration: const Duration(milliseconds: 300),
                    child: CircleAvatar(
                      maxRadius: 24,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        //final result = await showSearch(context: context, delegate: SearchDestinationDelegate());

                        //print(result);

                        final searchedPlaces = ref.read(searchedPlacesProvider);
                        final searchQuery = ref.read(searchQueryPlacesProvider);

                        showSearch<Place?>(
                                query: searchQuery,
                                context: context,
                                delegate: SearchPlaceDelegate(
                                    initialPlaces: searchedPlaces,
                                    searchPlaces: ref
                                        .read(searchedPlacesProvider.notifier)
                                        .searchPlacesByQuery))
                            .then((place) {
                          if (place == null) return;

                          print('PLACE SELECTED');
                          print(place.formattedAddress);

                          LatLng latLng = LatLng(place.location.latitude,
                              place.location.longitude);

                          ref.read(mapProvider.notifier).moveCamera(latLng);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 13),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 5))
                            ]),
                        child: const Text('Buscar dirección',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        //CURSOR MAP
        SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -22),
                    child: BounceInDown(
                        from: 100,
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 60,
                          color: Colors.deepOrange,
                        )),
                  ),
                ),
              ],
            )),

        Positioned(
            bottom: 50,
            left: 40,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: MaterialButton(
                minWidth: size.width - 120,
                color: Colors.blueAccent,
                elevation: 0,
                height: 50,
                shape: const StadiumBorder(),
                onPressed: () async {
                  
                  showLoadingMessage(context);

                  //sleep(const Duration(seconds: 10));

                  //Navigator.pop(context);
                },
                child: const Text('Confimar ubicación',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ))
      ]),
    );
  }
}

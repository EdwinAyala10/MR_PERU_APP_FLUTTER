import 'dart:convert';

import 'package:crm_app/features/location/presentation/providers/location_provider.dart';
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

class _CompanyMapView extends ConsumerWidget {
  //final CompanyCheckIn companyCheckIn;

  //const _CompanyCheckInView({required this.companyCheckIn});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const CameraPosition initialCameraPosition =
        CameraPosition(target: LatLng(-12.04318, -77.02824), zoom: 15);

    final size = MediaQuery.of(context).size;

    final locationState = ref.watch(locationProvider.notifier).state;

    print('lastKnownLocation: ${locationState.lastKnownLocation.toString()}');

    return SingleChildScrollView(
      child: Stack(children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: const GoogleMap(
            initialCameraPosition: initialCameraPosition,
            mapType: MapType.normal,
            /*compassEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,*/
            //polylines: polylines,
            //markers: markers,
            //onMapCreated: ( controller ) => mapBloc.add( OnMapInitialzedEvent(controller) ),
            //onCameraMove: ( position ) => mapBloc.mapCenter = position.target
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
                      onTap: () async {},
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
                        child: const Text('¿Dónde quieres ir?',
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
                color: Colors.black,
                elevation: 0,
                height: 50,
                shape: const StadiumBorder(),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text('Confimar ubicación',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300)),
              ),
            ))
      ]),
    );
  }
}

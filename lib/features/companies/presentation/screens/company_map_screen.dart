import 'package:flutter/material.dart';
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
    const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.43296265331129, -122.08832357078792), 
      zoom: 15
    );

    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Stack(
        children: [
          
          SizedBox(
            width: size.width,
            height: size.height,
            child: const GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: initialCameraPosition,
              /*compassEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,*/
              //polylines: polylines,
              //markers: markers,
              //onMapCreated: ( controller ) => mapBloc.add( OnMapInitialzedEvent(controller) ),
              //onCameraMove: ( position ) => mapBloc.mapCenter = position.target
            ),
          )
        ]
      ),
    );
  }
}


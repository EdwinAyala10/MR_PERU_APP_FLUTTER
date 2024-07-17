import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/location/presentation/providers/providers.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteCard extends ConsumerStatefulWidget {
  @override
  _RouteCardState createState() => _RouteCardState();
}

class _RouteCardState extends ConsumerState<RouteCard> {
  @override
  Widget build(BuildContext context) {

    final List<CompanyLocalRoutePlanner> listSelectedItems = ref.watch(routePlannerProvider).selectedItems;
    final List<CompanyLocalRoutePlanner> locales = ref.watch(routePlannerProvider).locales;

    return GestureDetector(
      onTap: () async {

        final gpsState = ref.read(gpsProvider.notifier).state;

        if (!gpsState.isAllGranted) {
          if (!gpsState.isGpsEnabled) {
            showSnackbar(context, 'Debe de habilitar el GPS');
          } else {
            showSnackbar(context, 'Es necesario el acceso a GPS');
            ref.read(gpsProvider.notifier).askGpsAccess();
          }
          //Navigator.pop(context);

          return;
        }

        showLoadingMessage(context);


        LatLng location = await ref.watch(locationProvider.notifier).currentPosition();

        List<CompanyLocalRoutePlanner> orderLocales = await ref.read(mapProvider.notifier).sortLocalesByDistance(location, locales);

        ref.read(routePlannerProvider.notifier).setLocalesOrder(orderLocales);

        print('location latitude: ${location.latitude}');
        print('location longitude: ${location.longitude}');
        Navigator.pop(context);

        ref.read(mapProvider.notifier).setLocation(location);

        context.push('/route_day_planner');


      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue, size: 40),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ver ruta del día',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                    '${listSelectedItems.length} Check-ins',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '24,44km · 0:44h en coche',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
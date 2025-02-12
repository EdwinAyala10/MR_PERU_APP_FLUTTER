import 'package:crm_app/features/location/presentation/providers/providers.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/shared/widgets/format_distance.dart';
import 'package:crm_app/features/shared/widgets/format_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteCard extends ConsumerStatefulWidget {
  @override
  _RouteCardState createState() => _RouteCardState();
}

class _RouteCardState extends ConsumerState<RouteCard> {
  @override
  Widget build(BuildContext context) {

    final List<CompanyLocalRoutePlanner> listSelectedItems = ref.watch(routePlannerProvider).selectedItems;
    final int totalDistance = ref.watch(mapProvider).totalDistance;
    final int totalDuration = ref.watch(mapProvider).totalDuration;

    return GestureDetector(
      onTap: () async {
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
                Text(
                  '${formatDistanceV2(totalDistance)} · ${formatDuration(totalDuration)} en coche',
                  style: const TextStyle(
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
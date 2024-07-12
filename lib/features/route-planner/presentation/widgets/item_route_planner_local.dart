import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemRoutePlannerLocal extends ConsumerWidget {
  CompanyLocalRoutePlanner local;
  final Function()? callbackOnTap;

  ItemRoutePlannerLocal({super.key, required this.local, required this.callbackOnTap});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    int? numCantidadLocal = int.tryParse(local.localCantidad ?? '0');
    numCantidadLocal = numCantidadLocal ?? 0;

    final List<CompanyLocalRoutePlanner> listItems = ref.watch(routePlannerProvider).selectedItems;
   
    bool exists = listItems.any((item) => item.ruc == local.ruc && item.localCodigo == local.localCodigo);

    print('CHECK: ${exists}');

    return ListTile(
      title: Text(local.localNombre,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(local.razon ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),  
          Row(
            children: [
              Text(local.clienteNombreEstado ?? ''),
              const Text(' - '),
              Text(local.clienteNombreTipo ?? ''),
            ],
          ),
          Text ((numCantidadLocal>1 ? local.localDistrito : local.localDireccion) ?? '' , style: const TextStyle(color: Colors.black45))
        ],
      ),
      leading: 
      /*Transform.scale(
        scale: 1.5,
        child: Checkbox(
          value: true, 
          onChanged: (bool? check) {
            print('check: ${check}');
          },
        ),
      )*/
      Icon(
        //Icons.check_box_outline_blank_outlined, size: 40,
        exists ? Icons.check_box : Icons.check_box_outline_blank, 

        size: 40, 
        color: primaryColor,
      )
      /*Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: secondaryColor,
            ),
            child: const Icon(
              Icons.business,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      )*/,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(local.calificacion ?? ''),
          Text(local.userreportName ?? '')
        ],
      ),
      //onTap: callbackOnTap,
      onTap: () {
        ref.read(routePlannerProvider.notifier).onCheckItem(local);
      },
    );
  }
}

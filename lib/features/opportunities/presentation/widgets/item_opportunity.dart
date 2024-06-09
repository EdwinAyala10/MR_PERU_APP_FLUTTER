import 'package:crm_app/config/config.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';

class ItemOpportunity extends StatelessWidget {
  final Opportunity opportunity;
  final Function()? callbackOnTap;

  const ItemOpportunity({super.key, required this.opportunity, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(opportunity.oprtNombre, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(opportunity.oprtNobbreEstadoOportunidad ?? ''),
          Text('Ruc: ${opportunity.oprtRuc ?? ''}'),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${opportunity.oprtProbabilidad ?? ''}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600)),
        ],
      ),
      leading: const Icon(Icons.work_rounded, color: secondaryColor, size: 40,),
      onTap: callbackOnTap,
    );
  }
}

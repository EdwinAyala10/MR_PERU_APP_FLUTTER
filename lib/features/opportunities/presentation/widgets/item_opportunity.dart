import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ItemOpportunity extends StatelessWidget {
  final Opportunity opportunity;
  final Function()? callbackOnTap;

  const ItemOpportunity({super.key, required this.opportunity, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(opportunity.oprtNombre),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado: ${opportunity.oprtNobbreEstadoOportunidad ?? ''}'),
          Text('Ruc: ${opportunity.oprtRuc ?? ''}'),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${opportunity.oprtProbabilidad ?? ''}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.green)),
        ],
      ),
      leading: const Icon(Icons.work_rounded),
      onTap: callbackOnTap,
    );
  }
}

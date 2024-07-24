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
      title: Text('${opportunity.razon ?? ''}', style: TextStyle(fontWeight: FontWeight.w500),),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(opportunity.razonComercial ?? '', style: TextStyle(fontWeight: FontWeight.w400),),
          Text(opportunity.oprtNombre == '' ? '-' : opportunity.oprtNombre, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),),
          Text(opportunity.oprtNobbreEstadoOportunidad ?? ''),
          if(opportunity.localDistrito != '') Text(opportunity.localDistrito ?? ''),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${opportunity.oprtProbabilidad ?? ''}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w600)),
          Text('${opportunity.oprtValor == '.00' ? '0.00' : opportunity.oprtValor}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600)),
        ],
      ),
      leading: const Icon(Icons.work_rounded, color: secondaryColor, size: 40,),
      onTap: callbackOnTap,
    );
  }
}

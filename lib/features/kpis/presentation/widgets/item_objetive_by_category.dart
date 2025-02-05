import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/kpis/domain/entities/objetive_by_category.dart';
import 'package:flutter/material.dart';

class ItemObjetiveByCategory extends StatelessWidget {
  final ObjetiveByCategory? model;
  final Function()? callbackOnTap;

  const ItemObjetiveByCategory({
    super.key,
    required this.model,
    required this.callbackOnTap,
  });

  @override
  Widget build(BuildContext context) {
    int? numCantidadLocal = int.tryParse('0');
    numCantidadLocal = numCantidadLocal ?? 0;

    return ListTile(
      title: Text('',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (true)
            Text(
              '',
              style: const TextStyle(
                color: primaryColor,
              ),
            ),
          Row(
            children: [
              Text(''),
              const Text(' - '),
              Text(''),
            ],
          ),
          Text((numCantidadLocal > 1 ? '' : '') ?? '',
              style: const TextStyle(color: Colors.black45))
        ],
      ),
      leading: Stack(
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
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
              width: 100,
              child: Text(
                '',
                style: TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis),
              )),
          Text('')
        ],
      ),
      onTap: callbackOnTap,
    );
  }
}

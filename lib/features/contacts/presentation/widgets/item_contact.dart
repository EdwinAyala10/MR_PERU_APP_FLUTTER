import 'package:crm_app/features/shared/shared.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemContact extends StatelessWidget {
  final Contact contact;
  final Function()? callbackOnTap;
  const ItemContact(
      {super.key, required this.contact, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.contactoDesc, overflow: TextOverflow.ellipsis, style: const TextStyle(
            fontWeight: FontWeight.w600
          ),),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contact.razon ?? ''),
          contact.contactoTelefonoc != ''
              ? Row(
                  children: [
                    const Icon(Icons.phone, size: 14),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(contact.contactoTelefonoc, overflow: TextOverflow.ellipsis)
                    ),
                  ],
                )
              : Container(),
          contact.contactoNombreCargo != ''
              ? Row(
                  children: [
                    const Icon(Icons.account_balance, size: 14),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(contact.contactoNombreCargo ?? '', overflow: TextOverflow.ellipsis)
                    ),
                  ],
                )
              : Container(),
          contact.contactoEmail != ''
              ? Row(
                  children: [
                    const Icon(Icons.mail, size: 14),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(contact.contactoEmail ?? '', overflow: TextOverflow.ellipsis)
                    ),
                  ],
                )
              : Container(),
          if (contact.actiIdTipoGestion != null) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 230, 255, 249),
                border: Border.all(color: Color.fromARGB(255, 21, 158, 124), width: 1.5),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ultima actividad: ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 96, 95, 95),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconsActivity(type: contact.actiIdTipoGestion!, size: 19),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    contact.actiNombreTipoGestion ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                ],
              ),
            )      
        ],
      ),
      //trailing: Text(contact.contactoCargo),
      leading: SvgPicture.asset(
        'assets/images/avatar.svg',
        height: 40.0,
        width: 40.0,
      ),
      onTap: callbackOnTap
      /*onTap: () {
        contextItem.push('/contact/${contact.id}');
      },*/
    );
  }
}

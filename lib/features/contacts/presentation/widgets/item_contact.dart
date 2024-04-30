import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:flutter/material.dart';

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
          
        ],
      ),
      //trailing: Text(contact.contactoCargo),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        radius: 24,
        child: Text(
          contact.contactoDesc.isNotEmpty ? contact.contactoDesc[0].toUpperCase() : '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      onTap: callbackOnTap
      /*onTap: () {
        contextItem.push('/contact/${contact.id}');
      },*/
    );
  }
}

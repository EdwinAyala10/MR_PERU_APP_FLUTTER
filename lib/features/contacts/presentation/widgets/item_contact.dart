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
      title: Text(contact.contactoDesc, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          contact.contactoTelefonof != ''
              ? Row(
                  children: [
                    const Icon(Icons.phone, size: 14),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(contact.contactoTelefonof, overflow: TextOverflow.ellipsis)
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
          
          Text('ID: ${contact.id}')
        ],
      ),
      //trailing: Text(contact.contactoCargo),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        radius: 30,
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

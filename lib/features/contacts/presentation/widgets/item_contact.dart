import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ItemContact extends StatelessWidget {
  final Contact contact;
  final Function()? callbackOnTap;
  const ItemContact(
      {super.key, required this.contact, required this.callbackOnTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.contactoDesc),
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
                    Text(contact.contactoTelefonof),
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
                    Text(contact.contactoNombreCargo ?? ''),
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
                    Text(contact.contactoEmail ?? ''),
                  ],
                )
              : Container(),
        ],
      ),
      //trailing: Text(contact.contactoCargo),
      leading: CircleAvatar(
        child: Text(
          contact.contactoDesc[0].toUpperCase(),
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

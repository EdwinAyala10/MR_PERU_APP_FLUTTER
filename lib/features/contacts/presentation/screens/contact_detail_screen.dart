import 'package:crm_app/features/contacts/presentation/providers/contact_provider.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ContactDetailScreen extends ConsumerWidget {
  final String contactId;

  ContactDetailScreen({
    required this.contactId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(contactProvider(contactId));

    final contact = contactState.contact;

    if (contactState.isLoading) {
      return FullScreenLoader();
    }

    if (contact == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                alignment: Alignment.center,
                child: const Text(
                  'No se encontro información del contacto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ))
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del contacto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/contact/${contact.id}');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, // Ocupa todo el ancho disponible
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      contact.contactoDesc.trim().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Ajusta el tamaño del CircleAvatar según tus necesidades
                  ),
                  const SizedBox(height: 7),
                  Text(
                    contact.contactoDesc,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'DATOS DE EMPRESA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ContainerCustom(
              label: 'RUC:',
              text: contact.ruc ?? '',
            ),
            ContainerCustom(
              label: 'Empresa:',
              text: contact.razon ?? '',
            ),
            const SizedBox(
              height: 10,
            ),
            ContainerCustom(
              label: 'Cargo:',
              text: contact.contactoCargo ?? '',
            ),
            ContainerCustom(
              label: 'Teléfono:',
              text: contact.contactoTelefonof ?? '',
              icon: Icons.call_sharp,
              callbackIcon: () {
                context.push(
                    '/activity_post_call/${contact.id}/${contact.contactoTelefonof}');

                //_showModalBottomSheet(context);

                //llamarTelefono(context, contact.contactoTelefonof);
              },
            ),
            ContainerCustom(
              label: 'Móvil:',
              text: contact.contactoTelefonoc ?? '',
            ),
            ContainerCustom(
              label: 'Correo electrónico:',
              text: contact.contactoEmail ?? '',
            ),
            ContainerCustom(
              label: 'Comentarios:',
              text: contact.contactoNotas ?? '',
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerCustom extends StatelessWidget {
  String label;
  String text;
  IconData? icon;
  Function()? callbackIcon;
  ContainerCustom(
      {super.key,
      required this.label,
      required this.text,
      this.icon,
      this.callbackIcon});

  @override
  Widget build(BuildContext context) {
    if (text == "") {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 247, 245, 245),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  maxLines: 10,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                icon != null
                    ? IconButton(
                        icon: Icon(icon),
                        iconSize: 30, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon,
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Contacto'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _ContactsView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo contacto'),
        icon: const Icon(Icons.add),
        onPressed: () {
          context.push('/contact/no-id');
        },
      ),
    );
  }
}

class _ContactsView extends ConsumerStatefulWidget {
  const _ContactsView();

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class Contact {
  final String name;
  final String nameCompany;
  final String comment;
  final String namePosition;

  Contact(this.name, this.nameCompany, this.comment, this.namePosition);
}

class _ContactsViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ((scrollController.position.pixels + 400) >=
          scrollController.position.maxScrollExtent) {
        //ref.read(productsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Contact> contacts = List.generate(
      50,
      (index) => Contact(
          'Pepito $index',
          'Empresa $index',
          'Comentario xxx',
          'Cargo $index' // Random revenue
          ), // Generate randomly if the company is active or inactive
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: contacts.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.nameCompany),
                Text(contact.comment),
              ],
            ),
            trailing: Text(
              contact.namePosition
            ),
            leading: const CircleAvatar(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 16
                  ),
                  ),
            ),
            onTap: () {
              context.push('/contact/no-id');
            },
          );
        },
      ),
    );
  }
}

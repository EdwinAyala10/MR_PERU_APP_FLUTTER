import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
import 'package:crm_app/features/contacts/presentation/widgets/item_contact.dart';
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
          context.push('/contact/new');
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
    final contactsState = ref.watch(contactsProvider);

    return contactsState.contacts.length > 0
        ? _ListContacts(contacts: contactsState.contacts)
        : const _NoExistData();
  }
}

class _ListContacts extends StatelessWidget {
  final List<Contact> contacts;
  const _ListContacts({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: contacts.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final contact = contacts[index];

          return ItemContact(contact: contact, callbackOnTap: () {
              context.push('/contact/${contact.id}');
          });
        },
      ),
    );
  }
}

class _NoExistData extends StatelessWidget {
  const _NoExistData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.business,
          size: 100,
          color: Colors.grey,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: const Text(
            'No hay contactos registradas',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

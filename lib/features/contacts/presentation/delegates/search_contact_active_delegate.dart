import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchContactsCallback = Future<List<Contact>> Function(String query, String ruc);
typedef ResetSearchQueryCallback = void Function();

class SearchContactDelegate extends SearchDelegate<Contact?> {
  final SearchContactsCallback searchContacts;
  final ResetSearchQueryCallback resetSearchQuery;
  List<Contact> initialContacts;
  String ruc;

  late StreamController<List<Contact>> debouncedContacts;
  late StreamController<bool> isLoadingStream;

  Timer? _debounceTimer;

  SearchContactDelegate({
    required this.searchContacts,
    required this.ruc,
    required this.resetSearchQuery,
    required this.initialContacts,
  }) : super(
          searchFieldLabel: 'Buscar contactos',
          searchFieldStyle: const TextStyle(color: Colors.black45, fontSize: 16),
        ) {
    _initializeStreams();
  }

  void _initializeStreams() {
    debouncedContacts = StreamController.broadcast();
    isLoadingStream = StreamController.broadcast();
  }

  void clearStreams() {
    debouncedContacts.close();
    isLoadingStream.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final contacts = await searchContacts(query, ruc);
      initialContacts = contacts;
      debouncedContacts.add(contacts);
      isLoadingStream.add(false);
    });
  }

  /*Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialContacts,
      stream: debouncedContacts.stream,
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];

        if (contacts.isEmpty) {
          return Center(
            child: Text(
              'No existen registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return ListView.separated(
          itemCount: contacts.length,
          itemBuilder: (context, index) => _ContactItem(
            contact: contacts[index],
            onContactSelected: (context, contact) {
              clearStreams();
              close(context, contact);
            },
          ),
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        );
      },
    );
  }*/

  Widget buildResultsAndSuggestions() {
    return FutureBuilder<List<Contact>>(
      future: searchContacts(query, ruc),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar los datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No existen registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else {
          final contacts = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemCount: contacts.length,
            itemBuilder: (context, index) => _ContactItem(
              contact: contacts[index],
              onContactSelected: (context, contact) {
                clearStreams();
                close(context, contact);
              },
            ),
          );
        }
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              spins: 10,
              infinite: true,
              child: IconButton(
                  onPressed: () => query = '',
                  icon: const Icon(Icons.refresh_rounded)),
            );
          }

          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
                onPressed: () => query = '', icon: const Icon(Icons.clear)),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          clearStreams();
          resetSearchQuery();
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return buildResultsAndSuggestions();
  }

  @override
  void close(BuildContext context, Contact? result) {
    query = '';
    clearStreams();
    resetSearchQuery();
    super.close(context, result);
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    clearStreams();
    _initializeStreams();
    _onQueryChanged(query);
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function onContactSelected;

  const _ContactItem({required this.contact, required this.onContactSelected});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onContactSelected(context, contact);
      },
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: size.width * 0.2,
                child: const Icon(Icons.perm_contact_cal, size: 42),
              ),

              const SizedBox(width: 2),

              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.contactoDesc,
                      style: textStyles.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contact.contactoTelefonof == "" ? const SizedBox() : Text(contact.contactoTelefonof ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                    contact.contactoNombreCargo == "" ? const SizedBox() : Text(contact.contactoNombreCargo ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

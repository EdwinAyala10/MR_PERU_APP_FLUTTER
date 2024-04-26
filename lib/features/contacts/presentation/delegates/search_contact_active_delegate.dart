import 'dart:async';

import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchContactsCallback = Future<List<Contact>> Function(
    String query, String ruc);

class SearchContactDelegate extends SearchDelegate<Contact?> {
  final SearchContactsCallback searchContacts;
  List<Contact> initialContacts;

  StreamController<List<Contact>> debouncedContacts =
      StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  String ruc;

  SearchContactDelegate({
    required this.searchContacts,
    required this.ruc,
    required this.initialContacts,
  }) : super(
          searchFieldLabel: 'Buscar contactos',
          // textInputAction: TextInputAction.done
        );

  void clearStreams() {
    debouncedContacts.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // if ( query.isEmpty ) {
      //   debouncedCompanies.add([]);
      //   return;
      // }

      final contacts = await searchContacts(query, ruc);
      initialContacts = contacts;
      debouncedContacts.add(contacts);
      isLoadingStream.add(false);
    });
  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialContacts,
      stream: debouncedContacts.stream,
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];

        /*return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) => _ContactItem(
            contact: contacts[index],
            onContactSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            },
          ),
        );*/

        return ListView.separated(
          itemCount: contacts.length,
          itemBuilder: (context, index) => _ContactItem(
            contact: contacts[index],
            onContactSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            },
          ),
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        );
      },
    );
  }

  // @override
  // String get searchFieldLabel => 'Buscar empresa';

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
                child: const Icon(Icons.blinds_outlined),
              ),

              const SizedBox(width: 10),

              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.contactoDesc,
                      style: textStyles.titleMedium,
                    ),
                    Text(contact.contactoTelefonof ?? ''),
                    Text(contact.contactoCargo ?? ''),
                    Text(contact.contactoNombreCargo ?? ''),
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

import 'dart:async';

import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
import 'package:crm_app/features/contacts/presentation/widgets/item_contact.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:crm_app/features/shared/widgets/no_exist_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacto',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center),
      ),
      body: const Column(
        children: [
          _SearchComponent(),
          Expanded(child: _ContactsView()),
        ],
      ),
      floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.add,
          callOnPressed: () {
            context.push('/contact/new');
          }),
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

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadNextPage(isRefresh: true);
      ref.read(contactsProvider.notifier).onChangeNotIsActiveSearch();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    String text = ref.watch(contactsProvider).textSearch;
    ref.read(contactsProvider.notifier).loadNextPage(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);

    if (contactsState.isLoading) {
      return LoadingModal();
    }

    return contactsState.contacts.length > 0
        ? _ListContacts(
            contacts: contactsState.contacts, 
            onRefreshCallback: _refresh,
            scrollController: scrollController,
          )
      : NoExistData(textCenter: 'No hay contactos registradas', icon: Icons.person);
  }
}

class _SearchComponent extends ConsumerWidget {
  const _SearchComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timer? _debounce;
    TextEditingController _searchController =
        TextEditingController(text: ref.read(contactsProvider).textSearch);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            style: const TextStyle(fontSize: 14.0),
            controller: _searchController,
            onChanged: (String value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                print('Searching for: $value');
                ref.read(contactsProvider.notifier).onChangeTextSearch(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar contacto...',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 18.0),
              hintStyle: const TextStyle(fontSize: 14.0, color: Colors.black38),
            ),
          ),
          if (ref.watch(contactsProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref.read(contactsProvider.notifier).onChangeNotIsActiveSearch();
                _searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
        ],
      ),
    );
  }
}

class _ListContacts extends ConsumerStatefulWidget {
  final List<Contact> contacts;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;

  const _ListContacts(
      {super.key, required this.contacts, required this.onRefreshCallback, required this.scrollController});

  @override
  _ListContactsState createState() => _ListContactsState();
}

class _ListContactsState extends ConsumerState<_ListContacts> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.contacts.isEmpty
        ? Center(
            child: RefreshIndicator(
                onRefresh: widget.onRefreshCallback,
                key: _refreshIndicatorKey,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: widget.onRefreshCallback,
                        child: const Text('Recargar'),
                      ),
                      const Center(
                        child: Text('No hay registros'),
                      ),
                    ],
                  ),
                )),
          )
        : NotificationListener(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels + 400 == scrollInfo.metrics.maxScrollExtent) {
              ref.read(contactsProvider.notifier).loadNextPage(isRefresh: false);
            }
            return false;
          },
          child: RefreshIndicator(
              onRefresh: widget.onRefreshCallback,
              notificationPredicate: defaultScrollNotificationPredicate,
              key: _refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.contacts.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final contact = widget.contacts[index];
          
                  return ItemContact(
                      contact: contact,
                      callbackOnTap: () {
                        context.push('/contact_detail/${contact.id}');
                        //context.push('/contact/${contact.id}');
                      });
                },
              )),
        );
  }
}

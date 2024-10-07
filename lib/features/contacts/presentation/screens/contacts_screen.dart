import 'dart:async';

import 'package:crm_app/features/shared/presentation/providers/ui_provider.dart';

import '../../domain/domain.dart';
import '../providers/contacts_provider.dart';
import '../providers/providers.dart';
import '../widgets/item_contact.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/loading_modal.dart';
import '../../../shared/widgets/no_exist_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contactos',
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
            ref.read(uiProvider.notifier).deleteCompanyActivity();
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
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        print('CARGANDO MAS');
        ref.read(contactsProvider.notifier).loadNextPage(isRefresh: false);
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).onChangeNotIsActiveSearchSinRefresh();
      ref.read(contactsProvider.notifier).loadNextPage(isRefresh: true);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.read(contactsProvider.notifier).loadNextPage(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);
    final isReload = contactsState.isReload;

    if (contactsState.isLoading) {
      return const LoadingModal();
    }

    return contactsState.contacts.length > 0
        ? _ListContacts(
            contacts: contactsState.contacts, 
            onRefreshCallback: _refresh,
            isReload: isReload,
            scrollController: scrollController,
          )
      : NoExistData(
        textCenter: 'No hay contactos registradas', 
        onRefreshCallback: _refresh, 
        icon: Icons.person);
  }
}


class _SearchComponent extends ConsumerStatefulWidget {
  const _SearchComponent({super.key});

  @override
  ConsumerState<_SearchComponent> createState() => __SearchComponentState();
}

class __SearchComponentState extends ConsumerState<_SearchComponent> {
   TextEditingController searchController = TextEditingController(
      //text: ref.read(routePlannerProvider).textSearch
    );


  @override
  Widget build(BuildContext context) {
    Timer? debounce;
    //TextEditingController searchController =
    //    TextEditingController(text: ref.read(companiesProvider).textSearch);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            style: const TextStyle(fontSize: 14.0),
            controller: searchController,
            onChanged: (String value) {
              if (debounce?.isActive ?? false) debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 500), () {
                //ref.read(companiesProvider.notifier).loadNextPage(value);
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
                ref
                    .read(contactsProvider.notifier)
                    .onChangeNotIsActiveSearch();
                searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
        ],
      ),
    );
  }
}


/*


class _SearchComponent extends ConsumerWidget {
  const _SearchComponent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timer? debounce;
    TextEditingController searchController =
        TextEditingController(text: ref.read(contactsProvider).textSearch);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            style: const TextStyle(fontSize: 14.0),
            controller: searchController,
            onChanged: (String value) {
              if (debounce?.isActive ?? false) debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 500), () {
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
                searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
        ],
      ),
    );
  }
}

*/

class _ListContacts extends ConsumerStatefulWidget {
  final List<Contact> contacts;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;
  final bool isReload;

  const _ListContacts(
      {required this.contacts, required this.onRefreshCallback, required this.scrollController, required this.isReload});

  @override
  _ListContactsState createState() => _ListContactsState();
}

class _ListContactsState extends ConsumerState<_ListContacts> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.contacts.isEmpty
        ? Center(
            child: RefreshIndicator(
                onRefresh: widget.onRefreshCallback,
                key: refreshIndicatorKey,
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
          /*onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels + 400 == scrollInfo.metrics.maxScrollExtent) {
              ref.read(contactsProvider.notifier).loadNextPage(isRefresh: false);
            }
            return false;
          },*/
          child: RefreshIndicator(
              onRefresh: widget.onRefreshCallback,
              notificationPredicate: defaultScrollNotificationPredicate,
              //key: refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.contacts.length,
                controller: widget.scrollController,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final contact = widget.contacts[index];

                  if (index + 1 == widget.contacts.length) {
                    if (widget.isReload) {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }

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

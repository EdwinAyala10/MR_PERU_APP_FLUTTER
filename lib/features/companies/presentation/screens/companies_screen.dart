import 'dart:async';

import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../widgets/item_company.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/loading_modal.dart';
import '../../../shared/widgets/no_exist_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Empresas',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center),
      ),
      body: const Column(
        children: [
          _SearchComponent(),
          Expanded(child: _CompaniesView()),
        ],
      ),
      floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.add,
          callOnPressed: () {
            context.push('/company/new');
          }),
    );
  }
}

class _CompaniesView extends ConsumerStatefulWidget {
  const _CompaniesView();

  @override
  _CompaniesViewState createState() => _CompaniesViewState();
}

class _CompaniesViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ((scrollController.position.pixels + 400) >=
          scrollController.position.maxScrollExtent) {
        ref.read(companiesProvider.notifier).loadNextPage(isRefresh: false);
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(companiesProvider.notifier).loadNextPage(isRefresh: true);
      ref.read(companiesProvider.notifier).onChangeNotIsActiveSearch();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    //String text = ref.watch(companiesProvider).textSearch;
    ref.read(companiesProvider.notifier).loadNextPage(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final companiesState = ref.watch(companiesProvider);

    if (companiesState.isLoading) {
      return LoadingModal();
    }

    return companiesState.companies.length > 0
      ? _ListCompanies(
          companies: companiesState.companies, 
          onRefreshCallback: _refresh,
          scrollController: scrollController,
      )
      : NoExistData(textCenter: 'No hay empresas registradas', icon: Icons.business);
  }
}

class _ListCompanies extends ConsumerStatefulWidget {
  final List<Company> companies;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;

  const _ListCompanies(
      {super.key, required this.companies, required this.onRefreshCallback, required this.scrollController});

  @override
  _ListCompaniesState createState() => _ListCompaniesState();
}

class _ListCompaniesState extends ConsumerState<_ListCompanies> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.companies.isEmpty
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
              ref.read(companiesProvider.notifier).loadNextPage(isRefresh: false);
            }
            return false;
          },
          child: RefreshIndicator(
              notificationPredicate: defaultScrollNotificationPredicate,
              onRefresh: widget.onRefreshCallback,
              //key: _refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.companies.length,
                //controller: widget.scrollController,
                //physics: const BouncingScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) =>   const Divider(),
                itemBuilder: (context, index) {
                  final company = widget.companies[index];
          
                  return ItemCompany(
                      company: company,
                      callbackOnTap: () {
                        context.push('/company_detail/${company.ruc}');
                      });
                },
              )),
        );
  }
}

class _SearchComponent extends ConsumerWidget {
  const _SearchComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timer? _debounce;
    TextEditingController _searchController =
        TextEditingController(text: ref.read(companiesProvider).textSearch);

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
                //ref.read(companiesProvider.notifier).loadNextPage(value);
                ref.read(companiesProvider.notifier).onChangeTextSearch(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar empresa...',
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
          if (ref.watch(companiesProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref
                    .read(companiesProvider.notifier)
                    .onChangeNotIsActiveSearch();
                _searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
        ],
      ),
    );
  }
}


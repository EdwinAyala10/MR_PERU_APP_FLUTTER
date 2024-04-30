import 'dart:async';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/companies/presentation/widgets/item_company.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    Timer? _debounce;

    final isActiveSearch = ref.watch(companiesProvider).isActiveSearch;

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Empresas', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20), textAlign: TextAlign.center) ,

        /*actions: [
          if (isActiveSearch) const SizedBox(width: 58),
          if (isActiveSearch)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  //controller: _searchController,
                  onChanged: (String value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      print('Searching for: $value');
                      ref
                          .read(companiesProvider.notifier)
                          .onChangeTextSearch(value);
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar empresa...',
                    //border: InputBorder.none,
                  ),
                ),
              ),
            ),
          if (isActiveSearch)
            IconButton(
              onPressed: () {
                //_searchController.clear();
                ref.read(companiesProvider.notifier).onChangeNotIsActiveSearch();
              },
              icon: const Icon(Icons.clear),
            ),
          if (!isActiveSearch)
            IconButton(
                onPressed: () {
                  ref.read(companiesProvider.notifier).onChangeIsActiveSearch();
                },
                icon: const Icon(Icons.search_rounded))
        ],*/
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
        //ref.read(productsProvider.notifier).loadNextPage();
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(companiesProvider.notifier).loadNextPage('');
      ref.read(companiesProvider.notifier).onChangeNotIsActiveSearch();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // Simula una operación asíncrona de actualización de datos
    //await Future.delayed(Duration(seconds: 1));
    //setState(() {
    // Simula la adición de nuevos datos o actualización de los existentes
    //items = List.generate(20, (index) => "Item ${index + 100}");
    String text = ref.watch(companiesProvider).textSearch;
    ref.read(companiesProvider.notifier).loadNextPage(text);
    //});
  }

  @override
  Widget build(BuildContext context) {
    final companiesState = ref.watch(companiesProvider);

    if (companiesState.isLoading) {
      return LoadingModal();
    }

    return companiesState.companies.length > 0
        ? _ListCompanies(companies: companiesState.companies, onRefreshCallback: _refresh)
        : const _NoExistData();
  }
}

class _ListCompanies extends StatelessWidget {
  final List<Company> companies;
  final Future<void> Function() onRefreshCallback;

  const _ListCompanies({super.key, required this.companies, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return companies.isEmpty 
      ? Center(
        child: RefreshIndicator(
          onRefresh: onRefreshCallback,
          key: _refreshIndicatorKey,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: onRefreshCallback,
                  child: const Text('Recargar'),
                ),
                const Center(
                  child: Text('No hay registros'),
                ),
              ],
            ),
          )
        ),
      ) : RefreshIndicator(
        onRefresh: onRefreshCallback,
        key: _refreshIndicatorKey,
        child: ListView.separated(
          itemCount: companies.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemBuilder: (context, index) {
            final company = companies[index];
        
            return ItemCompany(
                company: company,
                callbackOnTap: () {
                  context.push('/company_detail/${company.ruc}');
                });
          },
        )
      );
  }
}



class _SearchComponent extends ConsumerWidget {
  const _SearchComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Timer? _debounce;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            style: const TextStyle(fontSize: 12.0),
            //controller: _searchController,
            onChanged: (String value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                print('Searching for: $value');
                ref
                    .read(companiesProvider.notifier)
                    .onChangeTextSearch(value);
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
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 18.0),
              hintStyle: const TextStyle(fontSize: 12.0),
            ),
          ),
          if (ref.watch(companiesProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref.read(companiesProvider.notifier).onChangeNotIsActiveSearch();
              },
              icon: const Icon(Icons.clear, size: 18.0), 
            ),
        ],
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
            'No hay empresas registradas',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

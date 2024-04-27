import 'dart:async';

import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/item_opportunity.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    Timer? _debounce;

    final isActiveSearch = ref.watch(opportunitiesProvider).isActiveSearch;

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Oportunidades'),
        actions: [
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
                          .read(opportunitiesProvider.notifier)
                          .onChangeTextSearch(value);
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar oportunidad...',
                    //border: InputBorder.none,
                  ),
                ),
              ),
            ),
          if (isActiveSearch)
            IconButton(
              onPressed: () {
                //_searchController.clear();
                ref.read(opportunitiesProvider.notifier).onChangeNotIsActiveSearch();
              },
              icon: const Icon(Icons.clear),
            ),
            
          if (!isActiveSearch)
            IconButton(
                onPressed: () {
                  ref.read(opportunitiesProvider.notifier).onChangeIsActiveSearch();
                },
                icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _OpportunitiesView(),
      floatingActionButton: FloatingActionButtonCustom(
        iconData: Icons.add,
        callOnPressed: () {
        context.push('/opportunity/new');
      }),
    );
  }
}

class _OpportunitiesView extends ConsumerStatefulWidget {
  const _OpportunitiesView();

  @override
  _OpportunitiesViewState createState() => _OpportunitiesViewState();
}

class _OpportunitiesViewState extends ConsumerState {
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
      ref.read(opportunitiesProvider.notifier).loadNextPage('');
      ref.read(opportunitiesProvider.notifier).onChangeNotIsActiveSearch();
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
    String text = ref.watch(opportunitiesProvider).textSearch;
    ref.read(opportunitiesProvider.notifier).loadNextPage(text);
    //});
  }

  @override
  Widget build(BuildContext context) {
    final opportunitiesState = ref.watch(opportunitiesProvider);

    if (opportunitiesState.isLoading) {
      return LoadingModal();
    }

    return opportunitiesState.opportunities.length > 0
        ? _ListOpportunities(opportunities: opportunitiesState.opportunities, onRefreshCallback: _refresh)
        : const _NoExistData();
  }
}

class _ListOpportunities extends StatelessWidget {
  final List<Opportunity> opportunities;
  final Future<void> Function() onRefreshCallback;

  const _ListOpportunities({super.key, required this.opportunities, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return opportunities.isEmpty 
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
          )),
    ) 
    : RefreshIndicator(
            onRefresh: onRefreshCallback,
            key: _refreshIndicatorKey,
            child: ListView.separated(
              itemCount: opportunities.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (context, index) {
                final opportunity = opportunities[index];
                return ItemOpportunity(
                    opportunity: opportunity, callbackOnTap: () {
                      context.push('/opportunity/${opportunity.id}');
                    });
              },
            )
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
            'No hay oportunidades registradas',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

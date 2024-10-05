import 'dart:async';

import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/widgets/no_exist_listview.dart';

import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../widgets/item_opportunity.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/loading_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Oportunidades',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          textAlign: TextAlign.center,
        ),
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
        ],*/
      ),
      body: const Column(
        children: [
          _SearchComponent(),
          Expanded(child: _OpportunitiesView()),
        ],
      ),
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
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        print('CARGANDO MAS');
        ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: false);
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref
          .read(opportunitiesProvider.notifier)
          .onChangeNotIsActiveSearchSinRefresh();
      ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    //String text = ref.watch(opportunitiesProvider).textSearch;
    ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final opportunitiesState = ref.watch(opportunitiesProvider);
    final isReload = opportunitiesState.isReload;

    if (opportunitiesState.isLoading) {
      return const LoadingModal();
    }

    return opportunitiesState.opportunities.isNotEmpty
        ? _ListOpportunities(
            opportunities: opportunitiesState.opportunities,
            onRefreshCallback: _refresh,
            isReload: isReload,
            scrollController: scrollController,
          )
        : NoExistData(
            textCenter: 'No hay actividades registradas',
            onRefreshCallback: _refresh,
            icon: Icons.graphic_eq);
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
                ref
                    .read(opportunitiesProvider.notifier)
                    .onChangeTextSearch(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar oportunidad...',
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
          if (ref.watch(opportunitiesProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref
                    .read(opportunitiesProvider.notifier)
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
    TextEditingController searchController = TextEditingController(text: ref.read(opportunitiesProvider).textSearch);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
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
                ref
                    .read(opportunitiesProvider.notifier)
                    .onChangeTextSearch(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar oportunidad...',
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
              hintStyle: const TextStyle(fontSize: 14.0, color: Colors.black38),
            ),
          ),
          if (ref.watch(opportunitiesProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref.read(opportunitiesProvider.notifier).onChangeNotIsActiveSearch();
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

class _ListOpportunities extends ConsumerStatefulWidget {
  final List<Opportunity> opportunities;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;
  final bool isReload;

  const _ListOpportunities(
      {required this.opportunities,
      required this.onRefreshCallback,
      required this.isReload,
      required this.scrollController});

  @override
  _ListOpportunitiesState createState() => _ListOpportunitiesState();
}

class _ListOpportunitiesState extends ConsumerState<_ListOpportunities> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.opportunities.isEmpty
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
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels + 400 ==
                  scrollInfo.metrics.maxScrollExtent) {
                ref
                    .read(opportunitiesProvider.notifier)
                    .loadNextPage(isRefresh: false);
              }
              return false;
            },
            child: RefreshIndicator(
              notificationPredicate: defaultScrollNotificationPredicate,
              onRefresh: widget.onRefreshCallback,
              //key: refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.opportunities.length,
                controller: widget.scrollController,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final opportunity = widget.opportunities[index];

                  if (index + 1 == widget.opportunities.length) {
                    if (widget.isReload) {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }

                  return ItemOpportunity(
                    opportunity: opportunity,
                    callbackOnTap: () {
                      ref.read(selectedOp.notifier).state = opportunity;
                      ref.read(selectOpportunity.notifier).state = opportunity;
                      context.push('/opportunity_detail/${opportunity.id}');
                    },
                  );
                },
              ),
            ),
          );
  }
}

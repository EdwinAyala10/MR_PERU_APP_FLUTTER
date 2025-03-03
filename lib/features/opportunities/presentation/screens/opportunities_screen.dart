import 'dart:async';
import 'dart:developer';

import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/filter_active_opportunity.dart';
import 'package:crm_app/features/shared/presentation/providers/ui_provider.dart';
import 'package:crm_app/features/shared/widgets/no_exist_listview.dart';
import 'package:flutter/widgets.dart';

import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../widgets/item_opportunity.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/loading_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  ConsumerState<OpportunitiesScreen> createState() =>
      _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends ConsumerState<OpportunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool activeFilter = true;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        log("Tab seleccionada: ${_tabController.index}");
        if (_tabController.index == 0) {
          log("CUSTOM LOGIC FOR ACTIVO");
          setState(() {
            activeFilter = true;
          });
          return;
        }
        setState(() {
          activeFilter = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        drawer: SideMenu(scaffoldKey: scaffoldKey),
        appBar: AppBar(
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            onTap: (int index) {
              log("message: $index");
              _tabController.animateTo(index);
            },
            tabs: const [
              Tab(text: 'Activo'),
              Tab(text: 'En pausa'),
              Tab(text: 'Ganado'),
              Tab(text: 'Perdida'),
            ],
          ),
          title: const Text(
            'Oportunidades',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          actions: [
            Visibility(
              visible: activeFilter,
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                      minHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    builder: (context) => const FilterOpportunityActive(),
                  );
                },
                icon: const Icon(
                  Icons.filter_alt_sharp,
                ),
              ),
            ),
          ],
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
        body: Column(
          children: [
            const _SearchComponent(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  Center(
                    child: _OpportunitiesView(
                      type: "01,02,03,04",
                    ),
                  ),
                  Center(
                    child: _OpportunitiesView(
                      type: "05",
                    ),
                  ),
                  Center(
                    child: _OpportunitiesView(
                      type: "06",
                    ),
                  ),
                  Center(
                    child: _OpportunitiesView(
                      type: "07",
                    ),
                  ),
                ],
              ),
            ),

            /// COMENTADO POR PABLO
            // Expanded(child: _OpportunitiesView()),
          ],
        ),
        floatingActionButton: FloatingActionButtonCustom(
            iconData: Icons.add,
            callOnPressed: () {
              ref.read(uiProvider.notifier).deleteCompanyActivity();
              context.push('/opportunity/new');
            }),
      ),
    );
  }
}

class _OpportunitiesView extends ConsumerStatefulWidget {
  final String type;
  const _OpportunitiesView({required this.type});
  @override
  _OpportunitiesViewState createState() => _OpportunitiesViewState();
}

class _OpportunitiesViewState extends ConsumerState<_OpportunitiesView> {
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
          .updateTypeOpportunity(widget.type);

      ref
          .read(opportunitiesProvider.notifier)
          .onChangeNotIsActiveSearchSinRefresh();
      ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
      log('HERE SE LLAMA AQUI ');
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
              debounce = Timer(const Duration(seconds: 1), () {
                //ref.read(companiesProvider.notifier).loadNextPage(value);
                ref
                    .read(opportunitiesProvider.notifier)
                    .onChangeTextSearch(value);
              });
            },
            onFieldSubmitted: (value) {
              ref
                  .read(opportunitiesProvider.notifier)
                  .onChangeTextSearch(value);
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
                      log("Estoy entrandoo aqui");
                    },
                  );
                },
              ),
            ),
          );
  }
}

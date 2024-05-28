import 'dart:async';

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

    Timer? _debounce;

    final isActiveSearch = ref.watch(opportunitiesProvider).isActiveSearch;

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Oportunidades', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20), textAlign: TextAlign.center) ,
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
      if ((scrollController.position.pixels + 400) >=
          scrollController.position.maxScrollExtent) {
        ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
      }
      
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
      ref.read(opportunitiesProvider.notifier).onChangeNotIsActiveSearch();
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

    if (opportunitiesState.isLoading) {
      return LoadingModal();
    }

    return opportunitiesState.opportunities.length > 0
        ? _ListOpportunities(
          opportunities: opportunitiesState.opportunities, 
          onRefreshCallback: _refresh,
          scrollController: scrollController,
          )
        : const _NoExistData();
  }
}

class _SearchComponent extends ConsumerWidget {
  const _SearchComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Timer? _debounce;
    TextEditingController _searchController = TextEditingController(text: ref.read(opportunitiesProvider).textSearch);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
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
                _searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0), 
            ),
        ],
      ),
    );
  }
}


class _ListOpportunities extends ConsumerStatefulWidget {
  final List<Opportunity> opportunities;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;

  const _ListOpportunities({super.key, required this.opportunities, required this.onRefreshCallback, required this.scrollController});

  @override
  _ListOpportunitiesState createState() => _ListOpportunitiesState();
}

class _ListOpportunitiesState extends ConsumerState<_ListOpportunities> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.opportunities.isEmpty 
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
          ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: false);
        }
        return false;
      },
      child: RefreshIndicator(
              notificationPredicate: defaultScrollNotificationPredicate,
              onRefresh: widget.onRefreshCallback,
              key: _refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.opportunities.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (context, index) {
                  final opportunity = widget.opportunities[index];
                  return ItemOpportunity(
                      opportunity: opportunity, callbackOnTap: () {
                        context.push('/opportunity_detail/${opportunity.id}');
                      });
                },
              )
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
            'No hay oportunidades registradas',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

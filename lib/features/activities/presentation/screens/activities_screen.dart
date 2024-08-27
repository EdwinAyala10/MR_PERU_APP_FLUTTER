import 'dart:async';

import 'package:crm_app/features/activities/presentation/providers/docs_activitie_provider.dart';

import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../widgets/item_activity.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/loading_modal.dart';
import '../../../shared/widgets/no_exist_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Actividades',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center),
        /*actions: [
          if (isActiveSearch) const SizedBox(width: 58),
          if (isActiveSearch)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  focusNode: _focusNode,
                  //controller: _searchController,
                  onChanged: (String value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      print('Searching for: $value');
                      ref
                          .read(activitiesProvider.notifier)
                          .onChangeTextSearch(value);
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar actividad...',
                    //border: InputBorder.none,
                  ),
                ),
              ),
            ),
          if (isActiveSearch)
            IconButton(
              onPressed: () {
                //_searchController.clear();
                ref.read(activitiesProvider.notifier).onChangeNotIsActiveSearch();
              },
              icon: const Icon(Icons.clear),
            ),
            
          if (!isActiveSearch)
            IconButton(
                onPressed: () async {
                  await ref.read(activitiesProvider.notifier).onChangeIsActiveSearch();
                  //Future.delayed(Duration(milliseconds: 2000), () {
                    _focusNode.requestFocus();
                  //});
                },
                icon: const Icon(Icons.search_rounded))
        ],*/
      ),
      body: const Column(
        children: [
          _SearchComponent(),
          Expanded(child: _ActivitiesView()),
        ],
      ),
      floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.add,
          callOnPressed: () {
            context.push('/activity/new');
            /*showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '¿Qué deseas?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.airline_stops_sharp),
                      title: const Text('Crear nueva Actividad'),
                      onTap: () {
                        // Acción cuando se presiona esta opción
                        Navigator.pop(context); // Cierra el modal
                        context.push('/activity/no-id');

                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: const Text('Nueva Actividad Whatsapp'),
                      onTap: () {
                        // Acción cuando se presiona esta opción
                        //Navigator.pop(context);
                        context.push('/activity');
                         // Cierra el modal
                      },
                    ),
                  ],
                ),
              );
            },
          );*/
          }),
    );
  }
}

class _ActivitiesView extends ConsumerStatefulWidget {
  const _ActivitiesView();

  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ((scrollController.position.pixels + 400) >=
          scrollController.position.maxScrollExtent) {
        ref.read(activitiesProvider.notifier).loadNextPage(isRefresh: false);
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(activitiesProvider.notifier).loadNextPage(isRefresh: true);
      ref.read(activitiesProvider.notifier).onChangeNotIsActiveSearch();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    //String text = ref.watch(activitiesProvider).textSearch;
    ref.read(activitiesProvider.notifier).loadNextPage(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final activitiesState = ref.watch(activitiesProvider);

    if (activitiesState.isLoading) {
      return const LoadingModal();
    }

    return activitiesState.activities.isNotEmpty
        ? _ListActivities(
            activities: activitiesState.activities,
            onRefreshCallback: _refresh,
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
                ref.read(activitiesProvider.notifier).onChangeTextSearch(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar actividad...',
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
          if (ref.watch(activitiesProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref
                    .read(activitiesProvider.notifier)
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

/*class _SearchComponent extends ConsumerStatefulWidget {
  const _SearchComponent();

  @override
  _SearchComponentState createState() => _SearchComponentState();
}

class _SearchComponentState extends ConsumerState {
  @override
  Widget build(BuildContext context) {
    Timer? debounce;
    TextEditingController searchController =
        TextEditingController(text: ref.read(activitiesProvider).textSearch);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            style: const TextStyle(fontSize: 14.0),
            //initialValue:  ?? '',
            controller: searchController,
            onChanged: (String value) {
              if (debounce?.isActive ?? false) debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 500), () {
                ref.read(activitiesProvider.notifier).onChangeTextSearch(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar actividad...',
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
          if (ref.watch(activitiesProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref
                    .read(activitiesProvider.notifier)
                    .onChangeNotIsActiveSearch();
                searchController.text = '';
                /*setState(() {
                });*/
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
        ],
      ),
    );
  }
}*/

class _ListActivities extends ConsumerStatefulWidget {
  final List<Activity> activities;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;

  const _ListActivities(
      {required this.activities,
      required this.onRefreshCallback,
      required this.scrollController});

  @override
  _ListActivitiesState createState() => _ListActivitiesState();
}

class _ListActivitiesState extends ConsumerState<_ListActivities> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.activities.isEmpty
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
                    .read(activitiesProvider.notifier)
                    .loadNextPage(isRefresh: false);
              }
              return false;
            },
            child: RefreshIndicator(
              notificationPredicate: defaultScrollNotificationPredicate,
              onRefresh: widget.onRefreshCallback,
              key: refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.activities.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final activity = widget.activities[index];

                  return ItemActivity(
                      activity: activity,
                      callbackOnTap: () {
                        ref.read(selectedAC.notifier).state = activity;
                        context.push('/activity_detail/${activity.id}');
                      });
                },
              ),
            ),
          );
  }
}

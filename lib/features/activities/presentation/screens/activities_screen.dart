import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/activities/presentation/widgets/item_activity.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Actividades'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _ActivitiesView(),
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
        //ref.read(productsProvider.notifier).loadNextPage();
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(activitiesProvider.notifier).loadNextPage();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activitiesState = ref.watch(activitiesProvider);

    if (activitiesState.isLoading) {
      return LoadingModal();
    }

    return activitiesState.activities.length > 0
        ? _ListActivities(activities: activitiesState.activities)
        : const _NoExistData();
  }
}

class _ListActivities extends StatelessWidget {
  final List<Activity> activities;

  const _ListActivities({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: activities.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final activity = activities[index];

          return ItemActivity(
            activity: activity,
            callbackOnTap: () {
              context.push('/activity/${activity.id}');
            });
        },
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
            'No hay actividades registradas',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

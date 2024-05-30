import 'package:crm_app/config/config.dart';

import '../../../activities/domain/domain.dart';
import '../../../activities/presentation/providers/activities_provider.dart';
import '../../../activities/presentation/widgets/item_activity_small.dart';
import '../../../agenda/domain/domain.dart';
import '../../../agenda/presentation/providers/events_provider.dart';
import '../../../agenda/presentation/widgets/item_event_small.dart';
import '../../../kpis/domain/domain.dart';
import '../../../kpis/presentation/providers/kpis_provider.dart';
import '../../../location/presentation/providers/gps_provider.dart';
import '../../../opportunities/domain/domain.dart';
import '../../../opportunities/domain/entities/status_opportunity.dart';
import '../../../opportunities/presentation/providers/providers.dart';
import '../../../opportunities/presentation/widgets/item_opportunity_small.dart';
import '../../../shared/presentation/providers/notifications_provider.dart';
import '../../../shared/shared.dart';
import 'package:floating_action_bubble_custom/floating_action_bubble_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _animationController,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: _DashboardView()
      ),
      floatingActionButton: FloatingActionBubble(
        animation: _animation,
        onPressed: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Colors.white,
        iconData: Icons.add,
        shape: const CircleBorder(),
        backgroundColor: secondaryColor,
        items: <Widget>[
          /*BubbleMenu(
            title: 'Nueva tarea',
            iconColor: Colors.white,
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
            icon: Icons.task,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/task');
              _animationController.reverse();
            },
          ),*/
          BubbleMenu(
            title: 'Nueva Evento',
            iconColor: Colors.white,
            bubbleColor: secondaryColor,
            icon: Icons.event,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.go('/event/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Actividad',
            iconColor: Colors.white,
            bubbleColor: secondaryColor,
            icon: Icons.local_activity_outlined,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.go('/activity/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Oportunidad',
            iconColor: Colors.white,
            bubbleColor: secondaryColor,
            icon: Icons.work,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.go('/opportunity/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nuevo Contacto',
            iconColor: Colors.white,
            bubbleColor: secondaryColor,
            icon: Icons.perm_contact_cal,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.go('/contact/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Empresa',
            iconColor: Colors.white,
            bubbleColor: secondaryColor,
            icon: Icons.account_balance_rounded,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.go('/company/no-id');
              _animationController.reverse();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Put here the operations you want to execute when refreshing
    await Future.wait([
      ref.read(kpisProvider.notifier).loadNextPage(),
      ref.read(eventsProvider.notifier).loadNextPage(),
      ref.read(activitiesProvider.notifier).loadNextPage(isRefresh: true),
      ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true),

      //ref.read(opportunitiesProvider.notifier).loadStatusOpportunity(),
    ]);
  }
  
}

class _DashboardView extends ConsumerStatefulWidget {
  const _DashboardView();

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(kpisProvider.notifier).loadNextPage();
      ref.read(eventsProvider.notifier).loadNextPage();
      ref.read(activitiesProvider.notifier).loadNextPage(isRefresh: true);
      ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
      //ref.read(opportunitiesProvider.notifier).loadStatusOpportunity();
      ref.read(notificationsProvider.notifier).requestPermission();
    });

    final isGpsPermissionGranted =
        ref.read(gpsProvider.notifier).state.isGpsPermissionGranted;

    if (!isGpsPermissionGranted) {
      ref.read(gpsProvider.notifier).askGpsAccess();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kpisState = ref.watch(kpisProvider);

    final activitiesState = ref.watch(activitiesProvider);
    final opportunitiesState = ref.watch(opportunitiesProvider);
    final eventsState = ref.watch(eventsProvider);

    DateTime date = DateTime.now();
    String dateCurrent = DateFormat.yMMMMEEEEd('es').format(date);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Text(
              dateCurrent,
              style: const TextStyle(fontSize: 22, color: Colors.black54),
            ),
            const SizedBox(
              height: 4,
            ),
            kpisState.kpis.isNotEmpty
                ? Center(
                    child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //for (var kpi in kpisState.kpis)
                                for (var i = 0;
                                    i < 3 && i < kpisState.kpis.length;
                                    i++)
                                  progressKpi(
                                      percentage:
                                          (kpisState.kpis[i].porcentaje ?? 0)
                                              .toDouble(),
                                      title: kpisState
                                              .kpis[i].objrNombreCategoria ??
                                          '',
                                      subTitle: kpisState
                                              .kpis[i].objrNombrePeriodicidad ??
                                          '',
                                      subSubTitle: kpisState
                                              .kpis[i].objrNombreAsignacion ??
                                          '',
                                      advance: kpisState.kpis[i].totalRegistro
                                              .toString() ??
                                          '0',
                                      total: convertTypeCategory(
                                              kpisState.kpis[i]) ??
                                          '0'),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    Colors.black12, // Color de fondo del botón
                                borderRadius: BorderRadius.circular(
                                    4), // Bordes redondeados del botón
                              ),
                              child: TextButton(
                                onPressed: () {
                                  context.go('/kpis');
                                  // Aquí puedes implementar la lógica para "Mostrar Todo"
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Mostrar Todo',
                                      style: TextStyle(
                                        color: Colors
                                            .blue, // Color del texto del botón
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            primaryColor, // Color del círculo
                                      ),
                                      padding: const EdgeInsets.all(
                                          8), // Espacio interior alrededor del número
                                      child: Text(
                                        (kpisState.kpis.length).toString(),
                                        style: const TextStyle(
                                          color: Colors.white, // Color del número
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                  )
                : Container(),
            _ContainerDashboardEvents(
                linkedEventsList: eventsState.linkedEventsList),
            _ContainerDashboardActivities(
                activities: activitiesState.activities),
            /*_ContainerDashboardOpportunities(
                statusOpportunities: opportunitiesState.statusOpportunity),*/
            _ContainerDashboardOpportunities(
                opportunities: opportunitiesState.opportunities),
            const SizedBox(
              height: 68,
            )
          ],
        ),
      ),
    );
  }

  convertTypeCategory(Kpi kpi) {
    String res = kpi.objrCantidad ?? '';
    if (kpi.objrIdCategoria == '05') {
      res = ' ${res}K';
    } else {
      res = (double.parse(res).toInt()).toString();
    }
    return res;
  }
}

/*
class _ContainerDashboardOpportunitiesStatus extends StatelessWidget {
  List<StatusOpportunity> statusOpportunities;

  _ContainerDashboardOpportunitiesStatus(
      {super.key, required this.statusOpportunities});

  @override
  Widget build(BuildContext context) {
    double h1 = statusOpportunities.length * 80;
    double h2 = statusOpportunities.length * 70;

    if (statusOpportunities.length == 0) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      height: h1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: Text(
                  'Oportunidades',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: h2,
            child: ListView.builder(
              itemCount: statusOpportunities.length,
              itemBuilder: (context, index) {
                final status = statusOpportunities[index];

                Color color;

                if (status.recdNombre == '1. Contactado') {
                  color = Colors.red;
                } else if (status.recdNombre == '2. Primera visista') {
                  color = Colors.green;
                } else if (status.recdNombre == '3. Oferta enviada') {
                  color = Colors.blue;
                } else if (status.recdNombre == '4. Esperando pedido') {
                  color = Colors.yellow;
                } else if (status.recdNombre == '5. Vendido') {
                  color = Colors.cyanAccent;
                } else if (status.recdNombre == '6. Perdido') {
                  color = Colors.indigoAccent;
                } else {
                  color = Colors.brown;
                }

                return _ItemOpportunity(
                    title: status.recdNombre ?? '',
                    colorCustom: color,
                    porcentaje: status.totalPorcentaje ?? '');
              },
            ),
          )
        ],
      ),
    );
  }
}
*/



class _ContainerDashboardActivities extends StatelessWidget {
  List<Activity> activities;

  _ContainerDashboardActivities({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    double h1 = activities.length >= 2 ? 300 : 180;
    double h2 = activities.length >= 2 ? 220 : 100;

    if (activities.length == 0) {
      return SizedBox();
    }

    if (activities.length >= 0) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        height: h1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    'Actividades',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/activities');
                      // Acción cuando se presiona el botón
                    },
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: h2,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 2),
                  itemCount: activities.length > 5 ? 5 : activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];

                    return ItemActivitySmall(
                      activity: activity,
                    );
                  }),
            )
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }
}


class _ContainerDashboardOpportunities extends StatelessWidget {
  List<Opportunity> opportunities;

  _ContainerDashboardOpportunities({super.key, required this.opportunities});

  @override
  Widget build(BuildContext context) {
    double h1 = opportunities.length >= 2 ? 270 : 160;
    double h2 = opportunities.length >= 2 ? 200 : 80;

    /*if (opportunities.length == 0) {
      return const SizedBox();
    }*/

    if (opportunities.length >= 0) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        height: h1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    'Oportunidades',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/opportunities');
                      // Acción cuando se presiona el botón
                    },
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: h2,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 2),
                  itemCount: opportunities.length > 5 ? 5 : opportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity = opportunities[index];

                    return ItemOpportunitySmall(
                      opportunity: opportunity,
                      callbackOnTap: () {},
                    );
                  }),
            )
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }
}


class _ContainerDashboardEvents extends StatelessWidget {
  List<Event> linkedEventsList;

  _ContainerDashboardEvents({super.key, required this.linkedEventsList});

  @override
  Widget build(BuildContext context) {
    if (linkedEventsList.isEmpty) {
      return const SizedBox();
    }

    double h1 = linkedEventsList.length >= 2 ? 300 : 180;
    double h2 = linkedEventsList.length >= 2 ? 220 : 100;

    if (linkedEventsList.length >= 0) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        height: h1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    'Eventos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/agenda');
                      // Acción cuando se presiona el botón
                    },
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: h2,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 2),
                  itemCount:
                      linkedEventsList.length > 5 ? 5 : linkedEventsList.length,
                  itemBuilder: (context, index) {
                    final event = linkedEventsList[index];

                    return ItemEventSmall(
                      event: event,
                    );
                  }),
            )
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }
}

class _ItemOpportunity extends StatelessWidget {
  String title;
  Color colorCustom;
  String porcentaje;

  _ItemOpportunity(
      {super.key,
      required this.title,
      required this.colorCustom,
      required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorCustom.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      value: ((int.parse(porcentaje) ?? 0) / 100).toDouble(),
                      valueColor: AlwaysStoppedAnimation<Color>(colorCustom),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$porcentaje %',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
              child: Column(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(
                height: 6,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'NO. OPPT',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      Text(
                        '10',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('TOTAL',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text(
                        '101 \$',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('PONDERADO',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text(
                        '0 \$',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )),
        ],
      ),
    );
  }
}

class progressKpi extends StatelessWidget {
  double percentage;
  String title;
  String subTitle;
  String subSubTitle;
  String advance;
  String total;

  progressKpi({
    super.key,
    required this.percentage,
    required this.title,
    required this.subTitle,
    required this.subSubTitle,
    required this.advance,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 10,
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  value: ((percentage ?? 0) / 100).toDouble(),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue), // Color cuando está marcado
                  backgroundColor: Colors.grey,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    advance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.black38,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    total,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            subTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Text(
            subSubTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

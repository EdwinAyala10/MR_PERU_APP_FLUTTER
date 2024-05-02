import 'package:crm_app/features/activities/presentation/providers/activities_provider.dart';
import 'package:crm_app/features/activities/presentation/widgets/item_activity_small.dart';
import 'package:crm_app/features/agenda/presentation/providers/events_provider.dart';
import 'package:crm_app/features/agenda/presentation/widgets/item_event_small.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/kpis_provider.dart';
import 'package:crm_app/features/location/presentation/providers/gps_provider.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/presentation/providers/notifications_provider.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:floating_action_bubble_custom/floating_action_bubble_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

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
      body: const _DashboardView(),
      floatingActionButton: FloatingActionBubble(
        animation: _animation,
        onPressed: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Colors.blue,
        iconData: Icons.add,
        backgroundColor: Colors.white,
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
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
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
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
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
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
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
            bubbleColor: Colors.blue,
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
            bubbleColor: Colors.blue,
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
      ref.read(activitiesProvider.notifier).loadNextPage('');
      ref.read(opportunitiesProvider.notifier).loadStatusOpportunity();

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
                                            Colors.amber, // Color del círculo
                                      ),
                                      padding: const EdgeInsets.all(
                                          8), // Espacio interior alrededor del número
                                      child: Text(
                                        (kpisState.kpis.length).toString(),
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 12, 12,
                                              12), // Color del número
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
            if (eventsState.linkedEventsList.length >= 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                height: 300,
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
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          child: Text(
                            'Eventos',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
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
                      height: 220,
                      child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 2),
                          itemCount: eventsState.linkedEventsList.length > 5
                              ? 5
                              : eventsState.linkedEventsList.length,
                          itemBuilder: (context, index) {
                            final event = eventsState.linkedEventsList[index];

                            return ItemEventSmall(
                              event: event,
                            );
                          }),
                    )
                  ],
                ),
              ),
            if (activitiesState.activities.length >= 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                height: 300,
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
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          child: Text(
                            'Actividades',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
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
                      height: 220,
                      child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 2),
                          itemCount: activitiesState.activities.length > 5
                              ? 5
                              : activitiesState.activities.length,
                          itemBuilder: (context, index) {
                            final activity = activitiesState.activities[index];

                            return ItemActivitySmall(
                              activity: activity,
                            );
                          }),
                    )
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              height: 486,
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
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        child: Text(
                          'Oportunidades',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  Text(ref
                        .watch(opportunitiesProvider)
                        .statusOpportunity
                        .length.toString()),
                  /*ListView.builder(
                    itemCount: ref
                        .watch(opportunitiesProvider)
                        .statusOpportunity
                        .length,
                    itemBuilder: (context, index) {
                      final status = ref
                          .watch(opportunitiesProvider)
                          .statusOpportunity[index];

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
                  ),*/

                ],
              ),
            ),
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
            color: Colors.grey.withOpacity(0.25),
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

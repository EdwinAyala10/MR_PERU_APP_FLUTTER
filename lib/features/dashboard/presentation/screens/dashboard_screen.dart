import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/kpis_provider.dart';
import 'package:crm_app/features/location/presentation/providers/gps_provider.dart';
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
              context.push('/event/no-id');
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
              context.push('/activity/no-id');
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
              context.push('/opportunity/no-id');
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
              context.push('/contact/no-id');
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
              context.push('/company/no-id');
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

    DateTime date = DateTime.now();
    String dateCurrent = DateFormat.yMMMMEEEEd('es').format(date);

    return Center(
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
                                    title:
                                        kpisState.kpis[i].objrNombreCategoria ??
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
                              color: Colors.black12, // Color de fondo del botón
                              borderRadius: BorderRadius.circular(
                                  4), // Bordes redondeados del botón
                            ),
                            child: TextButton(
                              onPressed: () {
                                context.push('/kpis');
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
                                      color: Colors.amber, // Color del círculo
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
              : Container()
        ],
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

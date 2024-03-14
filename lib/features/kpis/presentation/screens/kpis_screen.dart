import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';


class KpisScreen extends StatelessWidget {
  const KpisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Objectivos'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _KpisView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.push('/kpi/new');

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

        },
      ),
    );
  }
}

class _KpisView extends ConsumerStatefulWidget {
  const _KpisView();

  @override
  _KpisViewState createState() => _KpisViewState();
}

class _KpisViewState extends ConsumerState {
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
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kpisState = ref.watch(kpisProvider);
    
    return kpisState.kpis.length > 0
        ? _ListKpis(kpis: kpisState.kpis)
        : const _NoExistData();
  }
}

class _ListKpis extends StatelessWidget {
  final List<Kpi> kpis;

  const _ListKpis({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: kpis.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final kpi = kpis[index];

          //DateTime fechaHora = DateTime.parse(DateTime.now());

          // Formatear la fecha
          //String fechaFormat = DateFormat('dd MMM yyyy').format(activity.actiFechaActividad);

          // Formatear la hora
          //String horaFormat = DateFormat('h:mm a').format(DateTime.now());

          return ListTile(
            title: Text(kpi.objrNombre),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kpi.objrNombreCategoria ?? ''),
                Text(kpi.objrNombreTipo ?? ''),
              ],
            ),
            trailing: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '',
                    //fechaFormat+' '+horaFormat, 
                    textAlign: TextAlign.right, 
                    style: TextStyle(
                      fontSize: 12,
                  )
                ),
              ],
            ),
            leading: const Icon(
              Icons.airline_stops_sharp
            ),
            onTap: () {
              context.push('/kpi/${kpi.id}');
            },
          );
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
            'No hay objectivos registrados',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

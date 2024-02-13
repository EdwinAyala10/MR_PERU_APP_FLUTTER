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
        title: const Text('Actividad'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _ActivitiesView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo Actividad'),
        icon: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
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
                        context.push('/activity');

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
          );

        },
      ),
    );
  }
}

class _ActivitiesView extends ConsumerStatefulWidget {
  const _ActivitiesView();

  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class Activity {
  final String name;
  final String nameCompany;
  final String comment;
  final String namePosition;
  final String price;

  Activity(this.name, this.nameCompany, this.comment, this.namePosition, this.price);
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
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Activity> activities = List.generate(
      50,
      (index) => Activity(
          'Oportunidad $index',
          'Estado: Oferta enviada $index',
          'Empresa xxx',
          '20 %',
          '1500 \$' // Random revenue
          ), // Generate randomly if the company is active or inactive
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: activities.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final contact = activities[index];
          return ListTile(
            title: const Text('Empresa XXX'),
            subtitle: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Llamada Telefónica'),
                Text('Comentario va aqui'),
              ],
            ),
            trailing:  const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('12 feb. 2024 1:51 a.m.', 
                    textAlign: TextAlign.right, 
                    style: TextStyle(
                      fontSize: 12,
                    )
                ),
                Text(
                  'Evans Arias', 
                  style: TextStyle(
                    fontSize: 13,
                  )
                ),
                Text(
                  'Hace 10 minutos', 
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
              context.go('/activity');
            },
          );
        },
      ),
    );
  }
}

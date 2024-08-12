import '../../domain/domain.dart';
import '../providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KpisScreen extends StatelessWidget {
  const KpisScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Objetivos', style: TextStyle(fontWeight: FontWeight.w600),),
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.replace('/dashboard');
            },
        ),
        centerTitle: true,
        /*actions: [
          IconButton(onPressed: () {

          }, icon: const Icon(Icons.search_rounded))
        ],*/
        
      ),
      body: const _KpisView(),
      
      /*floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.push('/kpi/new');
        },
      ),*/
    );
    //return _KpisView();
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

  Future<void> _refresh() async {
    // Simula una operación asíncrona de actualización de datos
    //await Future.delayed(Duration(seconds: 1));
    //setState(() {
    // Simula la adición de nuevos datos o actualización de los existentes
    //items = List.generate(20, (index) => "Item ${index + 100}");
    ref.read(kpisProvider.notifier).loadNextPage();
    //});
  }

  @override
  Widget build(BuildContext context) {
    final kpisState = ref.watch(kpisProvider);

    return kpisState.isLoading
        ? const _NoExistData()
        : _ListKpis(kpis: kpisState.kpis, onRefreshCallback: _refresh);
  }
}

class _ListKpis extends StatelessWidget {
  final List<Kpi> kpis;
  final Future<void> Function() onRefreshCallback;

  const _ListKpis(
      {required this.kpis, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return kpis.isEmpty
        ? Center(
            child: RefreshIndicator(
                onRefresh: onRefreshCallback,
                key: refreshIndicatorKey,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: onRefreshCallback,
                        child: const Text('Recargar'),
                      ),
                      const Center(
                        child: Text('No hay registros'),
                      ),
                    ],
                  ),
                )
            ),
          )
        : RefreshIndicator(
            onRefresh: onRefreshCallback,
            key: refreshIndicatorKey,
            child: ListView.separated(
              itemCount: kpis.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (context, index) {
                final kpi = kpis[index];

                return ListTile(
                  title: Text(kpi.objrNombreCategoria ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kpi.objrNombrePeriodicidad ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                      Text(kpi.objrNombreAsignacion ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${kpi.totalRegistro}/${convertTypeCategory(kpi)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black45))
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /*Text(kpi.objrNombreAsignacion ?? '',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                          )),*/
                      //for (var user in kpi.usuariosAsignados ?? [])
                      for (var i = 0; i < 2 && i < kpi.usuariosAsignados!.length; i++)
                        Text(
                          kpi.usuariosAsignados![i].userreportName ?? '', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle( fontSize: 10 ),
                        )

                    ],
                  ),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          value: ((kpi.porcentaje ?? 0) / 100).toDouble(),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue), // Color cuando está marcado
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      Text(
                        "${kpi.porcentaje!.round()}%", // El porcentaje se multiplica por 100 para mostrarlo correctamente
                        style: const TextStyle(
                          fontSize: 13, // Tamaño del texto
                          color: Colors.black, // Color del texto
                          fontWeight: FontWeight.bold, // Negrita
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    context.push('/kpi_detail/${kpi.id}');
                  },
                );
              },
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

class _NoExistData extends StatelessWidget {
  const _NoExistData();

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
            'Cargando...',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

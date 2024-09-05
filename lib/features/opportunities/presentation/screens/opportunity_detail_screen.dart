import 'dart:developer';

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/providers/activities_provider.dart';
import 'package:crm_app/features/activities/presentation/widgets/item_activity.dart';
import 'package:crm_app/features/agenda/domain/entities/event.dart';
import 'package:crm_app/features/agenda/presentation/providers/events_provider.dart';
import 'package:crm_app/features/agenda/presentation/widgets/item_event.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/documents/presentation/screens/documents_screen.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/op_create_document_response.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/op_delete_document_mapper.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/op_document_card.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:crm_app/features/shared/widgets/no_exist_listview.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/providers.dart';
import '../../../shared/shared.dart';
import 'package:intl/intl.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityDetailScreen({Key? key, required this.opportunityId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final companyState = ref.watch(companyProvider(companyId));

    // return Scaffold(
    //   body: companyState.isLoading
    //       ? const FullScreenLoader()
    //       : (companyState.company != null
    //           ? _CompanyDetailView(
    //               company: companyState.company!,
    //               /*contacts: companySecundaryState.contacts,
    //               opportunities: companyState.opportunities,
    //               activities: companyState.activities,
    //               events: companyState.events,
    //               companyLocales: companyState.companyLocales,*/
    //             )
    //           : Center(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   const Text('No se encontro datos de la empresa'),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   ElevatedButton(
    //                     onPressed: () {
    //                       // Acción cuando se presiona el botón
    //                       context.pop();
    //                     },
    //                     child: const Text('Regresar'),
    //                   ),
    //                 ],
    //               ),
    //             )),
    // );
    return _CompanyDetailView(opportunityId);
  }
}

class _CompanyDetailView extends ConsumerStatefulWidget {
  final String opportunityId;

  const _CompanyDetailView(this.opportunityId);

  @override
  _CompanyDetailViewState createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends ConsumerState<_CompanyDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   ref
    //       .watch(companyProvider(widget.company.ruc).notifier)
    //       .loadSecundaryDetails();
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      currentIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          centerTitle: true,
          title: const Text(
            "Oportunidades - Detalle",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.info,
                  size: 30,
                ),
                text: 'Informacion',
              ),
              Tab(
                icon: Icon(
                  Icons.event,
                  size: 30,
                ),
                text: 'Eventos',
              ),
              Tab(
                icon: Icon(
                  Icons.local_activity,
                  size: 30,
                ),
                text: 'Actividad',
              ),
              Tab(
                icon: Icon(
                  Icons.camera_enhance_sharp,
                  size: 30,
                ),
                text: 'Fotos',
              ),
              Tab(
                icon: Icon(
                  Icons.file_copy_sharp,
                  size: 30,
                ),
                text: 'Archivos',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push(
                  '/opportunity/${widget.opportunityId}',
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll
          children: [
            buildInformation(),
            buildEventsOportunity(),
            buildActivity(),
            buildPhotos(),
            buildDocuments()
          ],
        ),
      ),
    );
  }

  Widget buildEventsOportunity() {
    return EventsDetailView(
      opportunityId: widget.opportunityId,
    );
  }

  Widget buildActivity() {
    return const _ActivitiesView();
  }

  Widget buildInformation() {
    return OpportunityDetailView(
      opportunityId: widget.opportunityId,
    );
  }

  Widget buildPhotos() {
    return _PhotoView(_tabController);
  }

  Widget buildDocuments() {
    return _DocumentsView(_tabController);
  }
}

class OpportunityDetailView extends ConsumerWidget {
  final String opportunityId;

  const OpportunityDetailView({
    super.key,
    required this.opportunityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityState = ref.watch(opportunityProvider(opportunityId));
    final opportunity = opportunityState.opportunity;

    if (opportunityState.isLoading) {
      return const FullScreenLoader();
    }

    if (opportunity == null) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                alignment: Alignment.center,
                child: const Text(
                  'No se encontro información de la oportunidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ))
          ],
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   // title: const Text('Detalles de oportunidad'),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: const Icon(Icons.edit),
      //   //     onPressed: () {
      //   //       context.push('/opportunity/${opportunity.id}');
      //   //     },
      //   //   ),
      //   // ],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 0,
      //   backgroundColor: Colors.blueGrey,
      //   onPressed: () {},
      //   child: IconButton(
      //     icon: const Icon(
      //       Icons.edit,
      //       color: Colors.white,
      //     ),
      //     onPressed: () {
      //       context.push('/opportunity/${opportunity.id}');
      //     },
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  ContainerCustom(
                    label: 'Nombre de la oportunidad',
                    text: opportunity.oprtNombre,
                  ),
                  // Positioned(
                  //   right: 20,
                  //   top: 1,
                  //   child: SizedBox(
                  //     width: 50,
                  //     child: MaterialButton(
                  //       padding: EdgeInsets.zero,
                  //       shape: const RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.all(
                  //           Radius.circular(100),
                  //         ),
                  //       ),
                  //       color: Colors.blueGrey,
                  //       onPressed: () {},
                  //       child: IconButton(
                  //         icon: const Icon(
                  //           Icons.edit,
                  //           color: Colors.white,
                  //         ),
                  //         onPressed: () {
                  //           context.push('/opportunity/${opportunity.id}');
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              ContainerCustom(
                label: 'Estado',
                text: opportunity.oprtNobbreEstadoOportunidad ?? '',
              ),
              ContainerCustom(
                label: 'Probabilidad',
                text: '${opportunity.oprtProbabilidad}%',
              ),
              const ContainerCustom(
                label: 'Moneda',
                text: 'USD',
              ),
              ContainerCustom(
                label: 'Importe Total',
                text: opportunity.oprtValor.toString(),
              ),
              ContainerCustom(
                label: 'Fecha',
                text: DateFormat('dd-MM-yyyy').format(
                    opportunity.oprtFechaPrevistaVenta ?? DateTime.now()),
              ),
              ContainerCustom(
                label: 'Empresa',
                text: opportunity.oprtRazon ?? '',
              ),
              ContainerCustom(
                label: 'Local',
                text: opportunity.oprtLocalNombre ?? '',
              ),
              ContainerCustom(
                label: 'Contacto',
                text: opportunity.oprtNombreContacto ?? '',
              ),
              if (opportunity.arrayresponsables != null &&
                  opportunity.arrayresponsables!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Responsables',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        runSpacing: 4,
                        spacing: 8,
                        children:
                            opportunity.arrayresponsables!.map((responsable) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              responsable.userreportName ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ContainerCustom(
                label: 'Comentario',
                text: opportunity.oprtComentario ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContainerCustom extends StatelessWidget {
  final String label;
  final String text;
  final IconData? icon;
  final Function()? callbackIcon;
  final Widget? icon2;
  final Function()? callbackIcon2;
  const ContainerCustom(
      {super.key,
      required this.label,
      required this.text,
      this.icon,
      this.callbackIcon,
      this.icon2,
      this.callbackIcon2});

  @override
  Widget build(BuildContext context) {
    if (text == "") {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 247, 245, 245),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  maxLines: 10,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Expanded(child: SizedBox()),
                icon2 != null
                    ? IconButton(
                        icon: icon2!,
                        iconSize: 20, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon2,
                      )
                    : const SizedBox(),
                icon != null
                    ? IconButton(
                        icon: Icon(icon),
                        iconSize: 30, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class EventsDetailView extends ConsumerWidget {
  final String opportunityId;

  const EventsDetailView({
    super.key,
    required this.opportunityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsProvider);

    if (eventsState.isLoading) {
      return const FullScreenLoader();
    }

    if (eventsState.events.isEmpty) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity, // Ocupa todo el ancho disponible
              alignment: Alignment.center,
              child: const Text(
                'No se encontro información del evento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                await ref
                    .read(eventsProvider.notifier)
                    .loadNextPageByObtetivo(opportunityId);
              },
              icon: const Icon(
                Icons.refresh,
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   // title: const Text('Detalles de oportunidad'),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: const Icon(Icons.edit),
      //   //     onPressed: () {
      //   //       context.push('/opportunity/${opportunity.id}');
      //   //     },
      //   //   ),
      //   // ],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 0,
      //   backgroundColor: Colors.blueGrey,
      //   onPressed: () {},
      //   child: IconButton(
      //     icon: const Icon(
      //       Icons.edit,
      //       color: Colors.white,
      //     ),
      //     onPressed: () {
      //       context.push('/opportunity/${opportunity.id}');
      //     },
      //   ),
      // ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              //valueListenable: _selectedEvents,
              valueListenable: ValueNotifier(eventsState.events),
              builder: (context, value, _) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(eventsProvider.notifier)
                        .loadNextPageByObtetivo(opportunityId);
                  },
                  child: value.isNotEmpty
                      ? ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            final event = value[index];

                            return ItemEvent(
                                event: event,
                                callbackOnTap: () {
                                  //context.push('/event/${value[index].id}');
                                  context
                                      .push('/event_detail/${value[index].id}');
                                });
                          },
                        )
                      : ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Sin eventos',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoView extends ConsumerStatefulWidget {
  final TabController tabController;
  const _PhotoView(this.tabController);

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends ConsumerState<_PhotoView> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .watch(docOpportunitieProvider.notifier)
          .loadNextPage(type: TypeFileOp.photo);
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docsOpState = ref.watch(docOpportunitieProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButtonCustom(
        callOnPressed: () async {
          showModalAdd(
            context,
            ref,
            widget.tabController,
            TypeFileOp.photo,
          ); // Pasa el controlador aquí
        },
        iconData: Icons.add,
      ),
      body: docsOpState.documents.isEmpty
          ? Center(
              child: RefreshIndicator(
                  onRefresh: () async {
                    ref
                        .watch(docOpportunitieProvider.notifier)
                        .loadNextPage(type: TypeFileOp.photo);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .watch(docOpportunitieProvider.notifier)
                                .loadNextPage(type: TypeFileOp.photo);
                          },
                          child: const Icon(Icons.refresh),
                        ),
                        const Center(
                          child: Text('No hay registros'),
                        ),
                      ],
                    ),
                  )),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(docOpportunitieProvider.notifier).loadNextPage(
                      type: TypeFileOp.photo,
                    );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: MasonryGridView.count(
                  controller: scrollController,
                  // physics: const BouncingScrollPhysics(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisCount: 1,
                  itemCount: docsOpState.documents.length,
                  itemBuilder: (_, index) {
                    final document = docsOpState.documents[index];
                    return InkWell(
                      onTap: () async {
                        String fileUrl =
                            '${Environment.urlPublic}${document.oadjRutalRelativa}';
                        log(fileUrl.toString());
                        String fileName = document.oadjNombreOriginal;
                        log(fileName.toString());
                        await _requestStoragePermission(
                          context,
                          fileUrl,
                          fileName,
                        );
                      },
                      child: OPDocumentCard(
                        document: document,
                        callback: () {
                          showLoadingMessage(context);
                          ref
                              .read(docOpportunitieProvider.notifier)
                              .deleteDocument(document.oadjIdOportunidadAdjunto)
                              .then(
                            (OPDeleteDocumentResponse value) {
                              if (value.message != '') {
                                showSnackbar(context, value.message);
                                if (value.response) {}
                              }
                            },
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _DocumentsView extends ConsumerStatefulWidget {
  final TabController tabController;
  const _DocumentsView(this.tabController);

  @override
  _DocumentsViewState createState() => _DocumentsViewState();
}

class _DocumentsViewState extends ConsumerState<_DocumentsView> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .watch(docOpportunitieProvider.notifier)
          .loadNextPage(type: TypeFileOp.archive);
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docsOpState = ref.watch(docOpportunitieProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButtonCustom(
        callOnPressed: () async {
          showModalAdd(
            context,
            ref,
            widget.tabController,
            TypeFileOp.archive,
          ); // Pasa el controlador aquí
        },
        iconData: Icons.add,
      ),
      body: docsOpState.documents.isEmpty
          ? Center(
              child: RefreshIndicator(
                  onRefresh: () async {
                    ref
                        .watch(docOpportunitieProvider.notifier)
                        .loadNextPage(type: TypeFileOp.archive);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .watch(docOpportunitieProvider.notifier)
                                .loadNextPage(
                                  type: TypeFileOp.archive,
                                );
                          },
                          child: const Icon(Icons.refresh),
                        ),
                        const Center(
                          child: Text('No hay registros'),
                        ),
                      ],
                    ),
                  )),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(docOpportunitieProvider.notifier).loadNextPage(
                      type: TypeFileOp.archive,
                    );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: MasonryGridView.count(
                  controller: scrollController,
                  // physics: const BouncingScrollPhysics(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisCount: 1,
                  itemCount: docsOpState.documents.length,
                  itemBuilder: (_, index) {
                    final document = docsOpState.documents[index];
                    return GestureDetector(
                      onTap: () async {
                        String fileUrl =
                            '${Environment.urlPublic}${document.oadjRutalRelativa}';
                        String fileName = document.oadjNombreOriginal;
                        await _requestStoragePermission(
                          context,
                          fileUrl,
                          fileName,
                        );
                      },
                      child: OPDocumentCard(
                        document: document,
                        callback: () {
                          showLoadingMessage(context);
                          ref
                              .read(docOpportunitieProvider.notifier)
                              .deleteDocument(document.oadjIdOportunidadAdjunto)
                              .then(
                            (OPDeleteDocumentResponse value) {
                              if (value.message != '') {
                                showSnackbar(context, value.message);
                                if (value.response) {}
                              }
                            },
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

Future<void> _requestStoragePermission(context, fileUrl, fileName) async {
  var extStorageStatus = await Permission.manageExternalStorage.status;
  var storageStatus = await Permission.storage.request();
  if (!storageStatus.isGranted) {
    await Permission.storage.request();
  }
  if (!extStorageStatus.isGranted) {
    await Permission.manageExternalStorage.request();
  }
  if (extStorageStatus.isGranted || storageStatus.isGranted) {
    await downloadFile(fileUrl, fileName, context);
  } else if (extStorageStatus.isPermanentlyDenied ||
      storageStatus.isPermanentlyDenied) {
    // Permiso denegado permanentemente, mostrar diálogo para abrir la configuración
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Permiso de almacenamiento denegado permanentemente. Por favor habilítelo en la configuración.'),
        action: SnackBarAction(
          label: 'Abrir configuración',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  } else {
    // Permiso denegado
    showSnackbar(context, 'Permiso de almacenamiento denegado');
  }
}

Future<void> downloadFile(
    String fileUrl, String fileName, BuildContext context) async {
  final dio = Dio();

  try {
    final dir = await getExternalStorageDirectory();
    final filePath = '${dir!.path}/$fileName';

    final response = await dio.download(fileUrl, filePath);

    if (response.statusCode == 200) {
      await showNotification(filePath, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo descargado en: $filePath'),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () {
              openFile(filePath);
            },
          ),
        ),
      );
    } else {
      print('Error al descargar el archivo: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al descargar el archivo: $e');
  }
}

String agregarPrefijoPeru(String numero) {
  // Verificar si el número ya tiene el prefijo de país "+51"
  if (!numero.startsWith('+51')) {
    // Si no tiene el prefijo, agregarlo al principio
    return '+51$numero';
  }
  // Si ya tiene el prefijo, devolver el número sin cambios
  return numero;
}

Future<dynamic> showModalAdd(
  BuildContext context,
  WidgetRef ref,
  TabController tabController,
  TypeFileOp typeFileOp,
) {
  // Agrega el controlador como parámetro
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext modalContext) {
      return Container(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              typeFileOp == TypeFileOp.archive ? 'Documentos' : "Fotos",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Divider(),
            Visibility(
              visible: typeFileOp == TypeFileOp.archive,
              child: ListTile(
                title: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.file),
                    SizedBox(width: 10),
                    Center(child: Text('Subir Archivo')),
                  ],
                ),
                // minTileHeight: 12,
                onTap: () async {
                  Navigator.pop(modalContext);
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  String? fileName;
                  String? filePath;

                  if (result != null) {
                    fileName = result.files.single.name;
                    filePath = result.files.single.path;

                    showLoadingMessage(context);
                    await ref
                        .read(docOpportunitieProvider.notifier)
                        .createDocument(filePath!, fileName, typeFileOp)
                        .then((OPCreateDocumentResponse value) {
                      if (value.message != '') {
                        // showSnackbar(context, value.message);
                        // if (value.response) {}
                      }
                      Navigator.pop(context);
                    });
                  } else {
                    // El usuario canceló la selección del archivo
                  }
                },
              ),
            ),
            const Divider(),
            Visibility(
              visible: typeFileOp == TypeFileOp.photo,
              child: ListTile(
                title: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.plus),
                    SizedBox(width: 10),
                    Center(child: Text('Agregar Foto')),
                  ],
                ),
                // minTileHeight: 14,
                onTap: () async {
                  // Navigator.pop(modalContext);

                  // tabController.index = 1;

                  // context.push('/text_enlace');
                  // Navigator.pop(modalContext);

                  // tabController.index = 0;

                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  String? fileName;
                  String? filePath;

                  if (result != null) {
                    fileName = result.files.single.name;
                    filePath = result.files.single.path;
                    showLoadingMessage(context);
                    await ref
                        .read(docOpportunitieProvider.notifier)
                        .createDocument(filePath!, fileName, typeFileOp)
                        .then((OPCreateDocumentResponse value) {
                      // if (value.message != '') {
                      //   showSnackbar(context, value.message);
                      //   if (value.response) {}
                      // }
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  } else {
                    // El usuario canceló la selección del archivo
                  }
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 6),
            ListTile(
              // minTileHeight: 12,
              title: const Center(
                child: Text(
                  'CANCELAR',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              onTap: () {
                Navigator.pop(modalContext);
              },
            ),
          ],
        ),
      );
    },
  );
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
        ref
            .read(activitiesProvider.notifier)
            .loadNextPageActivitiesByOpportunities(
              isRefresh: false,
              opportunityId: ref.read(selectedOp.notifier).state?.id ?? '',
            );
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref
          .read(activitiesProvider.notifier)
          .loadNextPageActivitiesByOpportunities(
            isRefresh: true,
            opportunityId: ref.read(selectedOp.notifier).state?.id ?? '',
          );
      // ref.read(activitiesProvider.notifier).onChangeNotIsActiveSearch();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    String text = ref.watch(activitiesProvider).textSearch;
    ref.read(activitiesProvider.notifier).loadNextPageActivitiesByOpportunities(
          isRefresh: true,
          opportunityId: ref.read(selectedOp.notifier).state?.id ?? '',
        );
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
            icon: Icons.graphic_eq,
          );
  }
}

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
                    .loadNextPageActivitiesByOpportunities(
                        isRefresh: false,
                        opportunityId:
                            ref.read(selectedOp.notifier).state?.id ?? '');
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
                        // context.push('/activity_detail/${activity.id}');
                      });
                },
              ),
            ),
          );
  }
}




























































































































// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';

// // import '../../../activities/domain/domain.dart';
// // import '../../../activities/presentation/widgets/item_activity.dart';
// // import '../../../agenda/domain/domain.dart';
// // import '../../../agenda/presentation/widgets/item_event.dart';
// // import '../../../contacts/domain/domain.dart';
// // import '../../../contacts/presentation/widgets/item_contact.dart';
// // import '../../../opportunities/domain/domain.dart';
// // import '../../../opportunities/presentation/widgets/item_opportunity.dart';
// // import '../../../shared/widgets/floating_action_button_custom.dart';
// // import '../../../shared/widgets/floating_action_button_icon_custom.dart';
// // import '../../../shared/shared.dart';

// class OpportunityDetailScreen extends ConsumerWidget {
//   final String opportunityId;

//   const OpportunityDetailScreen({Key? key, required this.opportunityId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final companyState = ref.watch(companyProvider(companyId));

//     // return Scaffold(
//     //   body: companyState.isLoading
//     //       ? const FullScreenLoader()
//     //       : (companyState.company != null
//     //           ? _CompanyDetailView(
//     //               company: companyState.company!,
//     //               /*contacts: companySecundaryState.contacts,
//     //               opportunities: companyState.opportunities,
//     //               activities: companyState.activities,
//     //               events: companyState.events,
//     //               companyLocales: companyState.companyLocales,*/
//     //             )
//     //           : Center(
//     //               child: Column(
//     //                 mainAxisAlignment: MainAxisAlignment.center,
//     //                 children: [
//     //                   const Text('No se encontro datos de la empresa'),
//     //                   const SizedBox(
//     //                     height: 10,
//     //                   ),
//     //                   ElevatedButton(
//     //                     onPressed: () {
//     //                       // Acción cuando se presiona el botón
//     //                       context.pop();
//     //                     },
//     //                     child: const Text('Regresar'),
//     //                   ),
//     //                 ],
//     //               ),
//     //             )),
//     // );
//     return _CompanyDetailView();
//   }
// }

// class _CompanyDetailView extends ConsumerStatefulWidget {
//   // final Company company;
//   /*final List<Contact> contacts;
//   final List<Opportunity> opportunities;
//   final List<Activity> activities;
//   final List<Event> events;
//   final List<CompanyLocal> companyLocales;*/

//   const _CompanyDetailView(
//       // required this.company,
//       /*required this.contacts,
//       required this.opportunities,
//       required this.activities,
//       required this.events,
//       required this.companyLocales*/
//       );

//   @override
//   _CompanyDetailViewState createState() => _CompanyDetailViewState();
// }

// class _CompanyDetailViewState extends ConsumerState<_CompanyDetailView>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 6, vsync: this);
//     _tabController.addListener(_handleTabChange);

//     // WidgetsBinding.instance?.addPostFrameCallback((_) {
//     //   ref
//     //       .watch(companyProvider(widget.company.ruc).notifier)
//     //       .loadSecundaryDetails();
//     // });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _handleTabChange() {
//     setState(() {
//       _currentIndex = _tabController.index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TextStyle styleTitle =
//     //     const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);
//     // TextStyle styleLabel = const TextStyle(
//     //     fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87);
//     // TextStyle styleContent =
//     //     const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
//     // SizedBox spacingHeight = const SizedBox(height: 14);

//     return DefaultTabController(
//       length: 6, // Ahora tenemos 6 pestañas
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("",
//               style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                   overflow: TextOverflow.ellipsis)),
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(
//                   icon: Icon(
//                     Icons.info,
//                     size: 30,
//                   ),
//                   text: 'Informacion'),
//               Tab(
//                   icon: Icon(
//                     Icons.local_activity,
//                     size: 30,
//                   ),
//                   text: 'Actividad'),
//               Tab(
//                 icon: Icon(
//                   Icons.camera_enhance_sharp,
//                   size: 30,
//                 ),
//                 text: 'Fotos',
//               ),
//               Tab(
//                 icon: Icon(
//                   Icons.file_copy_sharp,
//                   size: 30,
//                 ),
//                 text: 'Archivos',
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 // context.push('/company/${widget.company.rucId}');
//               },
//             ),
//           ],
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: const [
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('fwefwe'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('Informacion'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('Locales'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('Cantacto'),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/documents/infrastructure/mapers/delete_document_response.dart';
import 'package:crm_app/features/documents/presentation/providers/documents_provider.dart';
import 'package:crm_app/features/documents/presentation/screens/screens.dart';
import 'package:crm_app/features/documents/presentation/widgets/document_card.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:go_router/go_router.dart';
// import '../../../activities/domain/domain.dart';
// import '../../../activities/presentation/widgets/item_activity.dart';
// import '../../../agenda/domain/domain.dart';
// import '../../../agenda/presentation/widgets/item_event.dart';
// import '../../../contacts/domain/domain.dart';
// import '../../../contacts/presentation/widgets/item_contact.dart';
// import '../../../opportunities/domain/domain.dart';
// import '../../../opportunities/presentation/widgets/item_opportunity.dart';
// import '../../../shared/widgets/floating_action_button_custom.dart';
// import '../../../shared/widgets/floating_action_button_icon_custom.dart';
// import '../../../shared/shared.dart';
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
  // final Company company;
  /*final List<Contact> contacts;
  final List<Opportunity> opportunities;
  final List<Activity> activities;
  final List<Event> events;
  final List<CompanyLocal> companyLocales;*/

  const _CompanyDetailView(this.opportunityId
      // required this.company,
      /*required this.contacts,
      required this.opportunities,
      required this.activities,
      required this.events,
      required this.companyLocales*/
      );

  @override
  _CompanyDetailViewState createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends ConsumerState<_CompanyDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      _currentIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TextStyle styleTitle =
    //     const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);
    // TextStyle styleLabel = const TextStyle(
    //     fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87);
    // TextStyle styleContent =
    //     const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
    // SizedBox spacingHeight = const SizedBox(height: 14);

    return DefaultTabController(
      length: 6, // Ahora tenemos 6 pestañas
      child: Scaffold(
        appBar: AppBar(
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
                  text: 'Informacion'),
              Tab(
                  icon: Icon(
                    Icons.local_activity,
                    size: 30,
                  ),
                  text: 'Actividad'),
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
          children: [
            buildInformation(),
            const SizedBox(
              child: Center(
                child: Text('Actividad'),
              ),
            ),
            buildPhotos(),
            buildDocuments()
          ],
        ),
      ),
    );
  }

  Widget buildInformation() {
    return OpportunityDetailView(
      opportunityId: widget.opportunityId,
    );
  }

  Widget buildPhotos() {
    return _DocumentsView(_tabController);
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
              ContainerCustom(
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

String agregarPrefijoPeru(String numero) {
  // Verificar si el número ya tiene el prefijo de país "+51"
  if (!numero.startsWith('+51')) {
    // Si no tiene el prefijo, agregarlo al principio
    return '+51$numero';
  }
  // Si ya tiene el prefijo, devolver el número sin cambios
  return numero;
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
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentsState = ref.watch(documentsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButtonCustom(
        callOnPressed: () async {
          showModalAdd(
            context,
            ref,
            widget.tabController,
          ); // Pasa el controlador aquí
        },
        iconData: Icons.add,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(documentsProvider.notifier).loadNextPage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: MasonryGridView.count(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            crossAxisCount: 1,
            itemCount: documentsState.listDocuments.length,
            itemBuilder: (_, index) {
              final document = documentsState.listDocuments[index];

              return GestureDetector(
                onTap: () async {
                  String fileUrl =
                      '${Environment.urlPublic}${document.adjtRutalRelativa}';
                  String fileName = document.adjtNombreOriginal;

                  await _requestStoragePermission(context, fileUrl, fileName);
                },
                child: DocumentCard(
                  document: document,
                  callback: () {
                    showLoadingMessage(context);
                    ref
                        .read(documentsProvider.notifier)
                        .deleteDocument(document.adjtIdAdjunto)
                        .then((DeleteDocumentResponse value) {
                      if (value.message != '') {
                        showSnackbar(context, value.message);
                        if (value.response) {}
                      }
                    });
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
  var status = await Permission.manageExternalStorage.status;
  if (!status.isGranted) {
    // Solicita permiso
    status = await Permission.manageExternalStorage.request();
  }

  if (status.isGranted) {
    // Permiso concedido
    await downloadFile(fileUrl, fileName, context);
  } else if (status.isPermanentlyDenied) {
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
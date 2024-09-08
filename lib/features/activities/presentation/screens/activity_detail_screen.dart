import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/activities/infrastructure/mappers/activitie_create_document_response.dart';
import 'package:crm_app/features/activities/infrastructure/mappers/activitie_delete_document_mapper.dart';
import 'package:crm_app/features/activities/presentation/providers/chat_provider.dart';
import 'package:crm_app/features/activities/presentation/providers/docs_activitie_provider.dart';
import 'package:crm_app/features/activities/presentation/screens/chat_screen.dart';
import 'package:crm_app/features/activities/presentation/widgets/activitie_document_card.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/documents/presentation/screens/documents_screen.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/providers.dart';
import '../../../shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String activityId;

  const ActivityDetailScreen({
    Key? key,
    required this.activityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ActivityDetailScreen(activityId);
  }
}

class _ActivityDetailScreen extends ConsumerStatefulWidget {
  final String opportunityId;
  const _ActivityDetailScreen(this.opportunityId);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<_ActivityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(chatProvider).disconnect();
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {}

  @override
  Widget build(BuildContext context) {

    //final activityState = ref.watch(activityProvider(widget.));

    return DefaultTabController(
      length: 4, // Ahora tenemos 6 pestañas
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              ref.read(chatProvider).disconnect();
              context.pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
          title: const Text(
            "Actividad - Detalle",
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
                  Icons.comment_rounded,
                  size: 30,
                ),
                text: 'Comentario',
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
            buildComents(),
            buildPhotos(),
            buildDocuments()
          ],
        ),
      ),
    );
  }

  Widget buildInformation() {
    return ActivityDetailView(
      activityId: widget.opportunityId,
    );
  }

  Widget buildComents() {
    final user = ref.read(authProvider).user;
    return ChatScreen(user?.code ?? '');
  }

  Widget buildDocuments() {
    return _DocumentsView(_tabController);
  }

  Widget buildPhotos() {
    return _PhotoView(_tabController);
  }
}

class ActivityDetailView extends ConsumerWidget {
  final String activityId;

  const ActivityDetailView({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityProvider(activityId));

    final activity = activityState.activity;

    if (activityState.isLoading) {
      return const Scaffold(body: FullScreenLoader());
    }

    if (activity == null) {
      return Scaffold(
        // appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                alignment: Alignment.center,
                child: const Text(
                  'No se encontro información de la actividad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ))
          ],
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Detalles de actividad',
      //     style: TextStyle(fontWeight: FontWeight.w700),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.edit),
      //       onPressed: activity.actiIdTipoRegistro == '01'
      //           ? () {
      //               context.push('/activity/${activity.id}');
      //             }
      //           : null,
      //     ),
      //   ],
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
              ContainerCustom(
                label: 'Tipo de gestión',
                text: activity.actiNombreTipoGestion,
              ),
              ContainerCustom(
                label: 'Fecha',
                text: DateFormat('dd-MM-yyyy')
                    .format(activity.actiFechaActividad),
              ),
              const SizedBox(
                height: 10,
              ),
              ContainerCustom(
                label: 'Hora',
                text: DateFormat('hh:mm a').format(
                    DateFormat('HH:mm:ss').parse(activity.actiHoraActividad)),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'DATOS DE LA GESTIÓN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              ContainerCustom(
                label: 'Empresa',
                text: activity.actiRazon ?? '',
              ),
              ContainerCustom(
                label: 'Oportunidad',
                text: activity.actiNombreOportunidad,
              ),
              if (activity.actividadesContacto!.length > 0)
                ContainerCustom(
                  label: 'Contacto',
                  text: activity.actividadesContacto?[0].contactoDesc ?? '',
                ),
              ContainerCustom(
                label: 'Responsable',
                text: activity.actiNombreResponsable ?? '',
              ),
              ContainerCustom(
                label: 'Comentario',
                text: activity.actiComentario,
              ),
              ContainerCustom(
                label: 'Fecha Registro Check In',
                text: activity.cchkFechaRegistroCheckIn ?? '',
              ),
              ContainerCustom(
                label: 'Comentario Check In',
                text: activity.cchkComentarioCheckIn ?? '',
              ),
              ContainerCustom(
                label: 'Fecha Registro Check Out',
                text: activity.cchkFechaRegistroCheckOut ?? '',
              ),
              ContainerCustom(
                label: 'Comentario Check Out',
                text: activity.cchkComentarioCheckOut ?? '',
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
  const ContainerCustom({
    super.key,
    required this.label,
    required this.text,
    this.icon,
    this.callbackIcon,
    this.icon2,
    this.callbackIcon2,
  });

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
              overflow: TextOverflow.ellipsis
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
                Expanded(
                  child: Text(
                    text,
                    maxLines: 10,
                    style: const TextStyle(
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis 
                    ),
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
          .watch(docActivitieProvider.notifier)
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
    final docsOpState = ref.watch(docActivitieProvider);
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
                        .watch(docActivitieProvider.notifier)
                        .loadNextPage(type: TypeFileOp.photo);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .watch(docActivitieProvider.notifier)
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
                ref.read(docActivitieProvider.notifier).loadNextPage(
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
                      child: ACDocumentCard(
                        document: document,
                        callback: () {
                          showLoadingMessage(context);
                          ref
                              .read(docActivitieProvider.notifier)
                              .deleteDocument(document.oadjIdOportunidadAdjunto)
                              .then(
                            (ACDeleteDocumentResponse value) {
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
          .watch(docActivitieProvider.notifier)
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
    final docsOpState = ref.watch(docActivitieProvider);
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
                        .watch(docActivitieProvider.notifier)
                        .loadNextPage(type: TypeFileOp.archive);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .watch(docActivitieProvider.notifier)
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
                ref.read(docActivitieProvider.notifier).loadNextPage(
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
                      child: ACDocumentCard(
                        document: document,
                        callback: () {
                          showLoadingMessage(context);
                          ref
                              .read(docActivitieProvider.notifier)
                              .deleteDocument(document.oadjIdOportunidadAdjunto)
                              .then(
                            (ACDeleteDocumentResponse value) {
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
                        .read(docActivitieProvider.notifier)
                        .createDocument(filePath!, fileName, typeFileOp)
                        .then((ACCreateDocumentResponse value) {
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
                        .read(docActivitieProvider.notifier)
                        .createDocument(filePath!, fileName, typeFileOp)
                        .then((ACCreateDocumentResponse value) {
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

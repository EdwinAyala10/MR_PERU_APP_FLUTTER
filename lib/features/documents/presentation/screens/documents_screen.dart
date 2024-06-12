import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/documents/infrastructure/mapers/create_document_response.dart';
import 'package:crm_app/features/documents/presentation/providers/documents_provider.dart';
import 'package:crm_app/features/documents/presentation/widgets/widgets.dart';
import 'package:crm_app/features/indicators/indicators.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/local_notifications/local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final documentsState = ref.watch(documentsProvider);

    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        drawer: SideMenu(scaffoldKey: scaffoldKey),
        appBar: AppBar(
          title: const Text('Documentos', style: TextStyle(fontWeight: FontWeight.w600)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Documentos'),
              Tab(text: 'Enlaces'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            documentsState.isLoading 
              ? const FullScreenLoader()
              : (documentsState.listDocuments != null
                ? const _DocumentsView()
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No se encontraron documentos'),
                        SizedBox(height: 10),
                        /*ElevatedButton(
                          onPressed: () {
                            //context.pop();
                          },
                          child: const Text('Regresar'),
                        ),*/
                      ],
                    ),
                  )),
            //const _LinksView(), 
            documentsState.isLoading 
              ? const FullScreenLoader()
              : (documentsState.listLinks != null
                ? const _LinksView()
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No se encontraron enlaces'),
                        const SizedBox(height: 10),
                        /*ElevatedButton(
                          onPressed: () {
                            //context.pop();
                          },
                          child: const Text('Regresar'),
                        ),*/
                      ],
                    ),
                  )),// Vista para Enlaces
          ],
        ),
        floatingActionButton: FloatingActionButtonCustom(
          callOnPressed: () async {
            showModalAdd(context, ref);
          },
          iconData: Icons.add,
        ),
      ),
    );
  }
}

class _DocumentsView extends ConsumerStatefulWidget {
  const _DocumentsView();

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

    return RefreshIndicator(
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
          itemBuilder: (context, index) {
            final document = documentsState.listDocuments[index];
            
            return GestureDetector(
              onTap: () async {
                String fileUrl = '${Environment.urlPublic}${document.adjtRutalRelativa}';
                String fileName = document.adjtNombreOriginal;
                String tipoRegistro = document.adjtIdTipoRegistro;
                String enlace = document.adjtEnlace ?? '';

                if (tipoRegistro == '01') { //Documento
                  await _requestStoragePermission(context, fileUrl, fileName);
                } else {
                  _copyToClipboard(context, enlace);
                }
              },
              child: DocumentCard(document: document)
            );
          },
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackbar(context, 'Texto copiado al portapapeles');
  }
  
  Future<void> _requestStoragePermission(context, fileUrl, fileName) async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // Solicita permiso
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      // Permiso concedido
      await downloadFile(fileUrl, fileName);
    } else if (status.isPermanentlyDenied) {
      // Permiso denegado permanentemente, mostrar diálogo para abrir la configuración
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permiso de almacenamiento denegado permanentemente. Por favor habilítelo en la configuración.'),
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

  Future<void> downloadFile(String fileUrl, String fileName) async {
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
                // Abre el archivo usando el paquete open_file
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

  Future<void> showNotification(String filePath, String filename) async {
    LocalNotifications.showLocalNotification(
      id: 2, 
      body: 'Descarga completa',
      title: 'El archivo se ha descargado correctamente $filename.',
      data: filePath
    );
  }

  // Función para abrir el archivo
  void openFile(String filePath) {
    OpenFile.open(filePath);
  }
}


class _LinksView extends ConsumerStatefulWidget {
  const _LinksView();

  @override
  _LinksViewState createState() => _LinksViewState();
}

class _LinksViewState extends ConsumerState<_LinksView> {
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

    return RefreshIndicator(
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
          itemCount: documentsState.listLinks.length,
          itemBuilder: (context, index) {
            final document = documentsState.listLinks[index];
            
            return GestureDetector(
              onTap: () async {
                String fileUrl = '${Environment.urlPublic}${document.adjtRutalRelativa}';
                String fileName = document.adjtNombreOriginal;
                String tipoRegistro = document.adjtIdTipoRegistro;
                String enlace = document.adjtEnlace ?? '';

                print('tipoRegistro: ${tipoRegistro}');
      
                if (tipoRegistro == '01') { //Documento
                  await _requestStoragePermission(context, fileUrl, fileName);
                } else {
                  _copyToClipboard(context, enlace);
                }
              },
              child: DocumentCard(document: document)
            );
          },
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackbar(context, 'Texto copiado al portapapeles');
  }
  
  Future<void> _requestStoragePermission(context, fileUrl, fileName) async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // Solicita permiso
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      // Permiso concedido
      await downloadFile(fileUrl, fileName);
    } else if (status.isPermanentlyDenied) {
      // Permiso denegado permanentemente, mostrar diálogo para abrir la configuración
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permiso de almacenamiento denegado permanentemente. Por favor habilítelo en la configuración.'),
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

  Future<void> downloadFile(String fileUrl, String fileName) async {
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
                // Abre el archivo usando el paquete open_file
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

  Future<void> showNotification(String filePath, String filename) async {
    LocalNotifications.showLocalNotification(
      id: 2, 
      body: 'Descarga completa',
      title: 'El archivo se ha descargado correctamente $filename.',
      data: filePath
    );
  }

  // Función para abrir el archivo
  void openFile(String filePath) {
    OpenFile.open(filePath);
  }
}



Future<dynamic> showModalAdd(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext modalContext) {
      return Container(
        padding: const EdgeInsets.all(14.0),
        //height: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Documentos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Divider(),
            ListTile(
              title: const Row(
                children: [
                  FaIcon(FontAwesomeIcons.file),
                  SizedBox(
                    width: 10,
                  ),
                  Center(child: Text('Subir documento')),
                ],
              ),
              minTileHeight: 12,
              onTap: () async {
                Navigator.pop(modalContext);

                FilePickerResult? result = await FilePicker.platform.pickFiles();

                String? fileName;
                String? filePath;

                if (result != null) {
                  fileName = result.files.single.name;
                  filePath = result.files.single.path;

                  showLoadingMessage(context);
                  
                  ref.read(documentsProvider.notifier).createDocument(filePath!, fileName).then((CreateDocumentResponse value) {
                    if (value.message != '') {
                      showSnackbar(context, value.message);
                      if (value.response) {
                        //Timer(const Duration(seconds: 3), () {
                        //context.push('/companies');
                        //context.pop();
                        //});
                      }
                    }
                    Navigator.pop(context);
                  });

                } else {
                  // El usuario canceló la selección del archivo
                }
              },
            ),
            const Divider(),
            ListTile(
              title: const Row(
                children: [
                  FaIcon(FontAwesomeIcons.plus),
                  SizedBox(
                    width: 10,
                  ),
                  Center(child: Text('Agregar enlace')),
                ],
              ),
              minTileHeight: 14,
              onTap: () async {
                Navigator.pop(modalContext);

                context.push('/text_enlace');
              },
            ),
            const Divider(),
            const SizedBox(height: 6),
            ListTile(
              minTileHeight: 12,
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

// Define el LinksNotifier y LinksState según tu lógica de manejo de datos
final linksProvider = StateNotifierProvider<LinksNotifier, LinksState>((ref) {
  return LinksNotifier();
});

class LinksNotifier extends StateNotifier<LinksState> {
  LinksNotifier() : super(LinksState());

  Future<void> loadNextPage() async {
    // Lógica para cargar más enlaces
  }
}

class LinksState {
  final List<Link> links;

  LinksState({this.links = const []});
}

class Link {
  final String title;
  final String url;

  Link({required this.title, required this.url});
}

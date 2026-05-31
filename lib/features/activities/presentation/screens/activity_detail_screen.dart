import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
import 'package:crm_app/features/shared/widgets/no_exist_listview.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart' hide ImageSource;

import '../../domain/domain.dart';
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
  final String activityId;
  const _ActivityDetailScreen(this.activityId);

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
    final activity = ref.read(selectedAC);
    return DefaultTabController(
      length: 4,
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
            "Detalle de la actividad",
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
                icon: Icon(Icons.info, size: 30),
                text: 'Informacion',
              ),
              Tab(
                icon: Icon(Icons.comment_rounded, size: 30),
                text: 'Chat',
              ),
              Tab(
                icon: Icon(Icons.camera_enhance_sharp, size: 30),
                text: 'Fotos',
              ),
              Tab(
                icon: Icon(Icons.file_copy_sharp, size: 30),
                text: 'Archivos',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: activity?.actiIdTipoRegistro == '01'
                  ? () {
                      context.push('/activity/${activity?.id}');
                    }
                  : null,
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
      activityId: widget.activityId,
    );
  }

  Widget buildEmailDetailView() {
    return EmailDetailView(
      activityId: widget.activityId,
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

class ActivityDetailView extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityDetailView({
    super.key,
    required this.activityId,
  });

  @override
  ConsumerState<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends ConsumerState<ActivityDetailView> {
  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityProvider(widget.activityId));

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

    // Si es Email (tipo '07'), mostrar el contenido de EmailDetailView
    if (activity.actiIdTipoGestion == '07') {
      return _buildEmailContent(activity);
    }

    // Para WhatsApp, Llamadas y otros tipos, mostrar el contenido normal
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
              if (activity.actiIdTipoGestion != '04')
                ContainerCustom(
                  label: 'Fecha',
                  text: DateFormat('dd-MM-yyyy')
                      .format(activity.actiFechaActividad),
                ),
              const SizedBox(
                height: 10,
              ),
              if (activity.actiIdTipoGestion != '04')
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
              
              if (activity.actiIdTipoGestion != '04')
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
              if(activity.actiIdTipoGestion == '04' && activity.coordenadalatitud != "")
                ListTile(
                  title: const Text(
                    'Mapa CheckIn', 
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                  
                  leading: const Icon(Icons.home_work_outlined, size: 34,),
                  trailing: GestureDetector(
                    onTap: () {
                    context.push('/view-map/${activity.coordenadalatitud},${activity.coordenadaLongitud}');
                  },
                    child: const Icon(Icons.place, size: 38, color: Colors.deepOrangeAccent),
                  ),
                  //onTap: ,
                )
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Contenido de Email - Mostrado cuando actiIdTipoGestion == '07'
  // ============================================================
  Widget _buildEmailContent(Activity activity) {
    final asunto = _resolveAsunto(activity);
    final bodyContent = _cleanHtmlContent(
      _resolveBodyContent(activity),
      asunto,
    );
    final attachments = activity.attachments ?? [];
    
    print('========== EMAIL CONTENT DEBUG ==========');
    print('Activity ID: ${activity.id}');
    print('Attachments count: ${attachments.length}');
    if (attachments.isNotEmpty) {
      for (var i = 0; i < attachments.length; i++) {
        print('Attachment $i:');
        print('  - name: ${attachments[i].name}');
        print('  - type: ${attachments[i].contentType}');
        print('  - size: ${attachments[i].size}');
        print('  - contentBytes length: ${attachments[i].contentBytes.length}');
      }
    }
    print('=========================================');

    String contactoNombre = '';
    final lista = activity.actividadesContacto ?? [];
    if (lista.isNotEmpty) {
      contactoNombre = lista[0].contactoDesc ?? '';
    }

    final emailFrom = activity.emlsEmailFrom ?? '';
    final paraText = _formatRecipients(
        activity.toRecipients ?? [], activity.emlsEmailTo);
    final ccText = _formatRecipients(activity.ccRecipients ?? [], null);
    final bccText = _formatRecipients(activity.bccRecipients ?? [], null);

    final fecha = DateFormat('dd-MM-yyyy').format(activity.actiFechaActividad);
    final horaCompleta = activity.actiHoraActividad;
    String horaFormateada = '';
    try {
      horaFormateada = DateFormat('hh:mm a').format(
        DateFormat('HH:mm:ss').parse(
          horaCompleta.length >= 8 ? horaCompleta.substring(0, 8) : horaCompleta,
        ),
      );
    } catch (_) {
      horaFormateada = horaCompleta;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // -------- INFORMACIÓN --------
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'INFORMACIÓN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              ContainerCustom(label: 'Fecha', text: fecha),
              ContainerCustom(label: 'Hora', text: horaFormateada),

              // -------- REFERENCIAS --------
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'REFERENCIAS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              ContainerCustom(label: 'Empresa', text: activity.actiRazon ?? ''),
              ContainerCustom(label: 'Contacto', text: contactoNombre),
              ContainerCustom(
                label: 'Responsable',
                text: activity.actiNombreResponsable ?? '',
              ),

              // -------- DETALLE DEL CORREO --------
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'DETALLE DEL CORREO',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              ContainerCustom(label: 'De', text: emailFrom),
              ContainerCustom(label: 'Para', text: paraText),
              ContainerCustom(label: 'CC', text: ccText),
              ContainerCustom(label: 'BCC', text: bccText),
              ContainerCustom(label: 'Asunto', text: asunto),

              // -------- CUERPO DEL CORREO (HTML renderizado) --------
              HtmlContainerCustom(
                label: 'Cuerpo del correo',
                htmlData: bodyContent,
              ),

              // -------- ADJUNTOS --------
              if (attachments.isNotEmpty) _buildAttachmentsSection(attachments),

              // -------- METADATOS --------
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'METADATOS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              ContainerCustom(label: 'Identificador', text: activity.id),
              ContainerCustom(
                label: 'Fecha de creación',
                text: DateFormat('dd/MM/yyyy HH:mm').format(activity.actiFechaActividad),
              ),
              ContainerCustom(
                label: 'Creado por',
                text: activity.actiNombreResponsable ?? '',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Helpers para Email ----
  String _formatRecipients(List<EmailRecipient> rec, String? fallback) {
    if (rec.isNotEmpty) {
      final first = rec.first;
      var text = first.name.isNotEmpty ? first.name : first.address;
      if (rec.length > 1) text += ' +${rec.length - 1}';
      return text;
    } else if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return '';
  }

  String _cleanHtmlContent(String html, String asunto) {
    if (html.isEmpty || asunto.isEmpty) return html;
    final escaped = RegExp.escape(asunto);
    final patterns = [
      RegExp(r'<h[1-6][^>]*>\s*' + escaped + r'\s*</h[1-6]>', caseSensitive: false),
      RegExp(r'<p[^>]*>\s*' + escaped + r'\s*</p>', caseSensitive: false),
      RegExp(r'<div[^>]*>\s*' + escaped + r'\s*</div>', caseSensitive: false),
      RegExp(r'<strong[^>]*>\s*' + escaped + r'\s*</strong>', caseSensitive: false),
      RegExp(r'<b[^>]*>\s*' + escaped + r'\s*</b>', caseSensitive: false),
    ];
    var cleaned = html;
    for (final p in patterns) {
      cleaned = cleaned.replaceFirst(p, '');
    }
    return cleaned;
  }

  String _resolveAsunto(Activity activity) {
    final emlsAsunto = (activity.emlsAsunto ?? '').trim();
    if (emlsAsunto.isNotEmpty) return emlsAsunto;
    final subject = (activity.subject ?? '').trim();
    if (subject.isNotEmpty) return subject;
    return 'Sin asunto';
  }

  String _resolveBodyContent(Activity activity) {
    final html = (activity.emailHtmlContent ?? '').trim();
    if (html.isNotEmpty) return html;
    final comentario = activity.actiComentario.trim();
    if (comentario.isNotEmpty) return comentario;
    return '<p>Sin contenido</p>';
  }

  Widget _buildAttachmentsSection(List<EmailAttachment> attachments) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            'Adjuntos (${attachments.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 247, 245, 245),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: attachments.map((attachment) {
              return InkWell(
                onTap: () => _openAttachment(context, attachment),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(_iconForAttachment(attachment),
                          size: 28, color: const Color(0xFF0092c7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0092c7),
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatFileSize(attachment.size),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.download_rounded,
                          size: 22, color: Color(0xFF0092c7)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _iconForAttachment(EmailAttachment a) {
    final t = a.contentType.toLowerCase();
    final n = a.name.toLowerCase();
    if (t.contains('pdf') || n.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (t.contains('image') ||
        n.endsWith('.png') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.gif')) return Icons.image;
    if (t.contains('word') || n.endsWith('.doc') || n.endsWith('.docx')) {
      return Icons.description;
    }
    if (t.contains('excel') ||
        t.contains('spreadsheet') ||
        n.endsWith('.xls') ||
        n.endsWith('.xlsx')) return Icons.table_chart;
    if (t.contains('zip') || n.endsWith('.zip')) return Icons.folder_zip;
    if (t.contains('video') || n.endsWith('.mp4')) return Icons.videocam;
    if (t.contains('audio') || n.endsWith('.mp3') || n.endsWith('.wav')) {
      return Icons.audiotrack;
    }
    return Icons.attach_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _openAttachment(
      BuildContext context, EmailAttachment attachment) async {
    print('========== TAP ON ATTACHMENT ==========');
    print('Name: ${attachment.name}');
    print('ContentBytes length: ${attachment.contentBytes.length}');
    
    if (attachment.contentBytes.isEmpty) {
      print('ERROR: ContentBytes empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo no tiene contenido')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Abriendo archivo...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      print('Starting decode process in Isolate...');
      
      // Decodificar base64 en Isolate (NO bloquea UI)
      final bytes = await compute(_decodeBase64InIsolate, attachment.contentBytes);
      print('Decoded ${bytes.length} bytes');

      // Detectar extensión real desde bytes
      final realExt = _detectExtensionFromBytes(bytes);
      String fileName = attachment.name;
      if (realExt.isNotEmpty &&
          !fileName.toLowerCase().endsWith('.$realExt')) {
        final dot = fileName.lastIndexOf('.');
        if (dot > 0) fileName = fileName.substring(0, dot);
        fileName = '$fileName.$realExt';
      }

      // Guardar y abrir
      print('Getting temp directory...');
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      print('File path: $filePath');
      
      final file = File(filePath);
      print('Writing ${bytes.length} bytes to file...');
      await file.writeAsBytes(bytes);
      print('File written successfully');

      if (context.mounted) Navigator.of(context).pop();

      print('Opening file with OpenFile...');
      final result = await OpenFile.open(filePath);
      print('OpenFile result: type=${result.type}, message=${result.message}');
      
      if (result.type == ResultType.noAppToOpen && context.mounted) {
        // No hay app para abrir el archivo, mostrar opciones
        print('No app to open, showing options...');
        _showFileOptionsDialog(context, filePath, fileName);
      } else if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir: ${result.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _detectExtensionFromBytes(List<int> b) {
    if (b.length < 4) return '';
    if (b[0] == 0x25 && b[1] == 0x50 && b[2] == 0x44 && b[3] == 0x46) return 'pdf';
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'png';
    if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return 'jpg';
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return 'gif';
    if (b[0] == 0x50 && b[1] == 0x4B && b[2] == 0x03 && b[3] == 0x04) return 'zip';
    if (b[0] == 0xD0 && b[1] == 0xCF && b[2] == 0x11 && b[3] == 0xE0) return 'doc';
    return '';
  }

  void _showFileOptionsDialog(BuildContext context, String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00A8DD).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFF00A8DD),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Previsualizar archivo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00607D),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Deseas previsualizar este documento?',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openInternalPdfViewer(context, filePath, fileName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A8DD),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text(
              'Ver archivo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _openInternalPdfViewer(BuildContext context, String filePath, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PdfViewerScreen(
          filePath: filePath,
          fileName: fileName,
        ),
      ),
    );
  }

  Future<void> _saveToDownloads(BuildContext context, String sourcePath, String fileName) async {
    try {
      // Pedir permisos de almacenamiento
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se necesita permiso de almacenamiento')),
          );
        }
        return;
      }

      // Obtener directorio de descargas
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo acceder al almacenamiento')),
          );
        }
        return;
      }

      // Copiar archivo a Descargas
      final downloadsPath = '/storage/emulated/0/Download/$fileName';
      final sourceFile = File(sourcePath);
      await sourceFile.copy(downloadsPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo guardado en Descargas: $fileName'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error saving to downloads: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
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
                overflow: TextOverflow.ellipsis),
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
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
          ? NoExistData(
              textCenter: 'No hay fotos registrados',
              onRefreshCallback: () async {
                ref
                    .watch(docActivitieProvider.notifier)
                    .loadNextPage(type: TypeFileOp.photo);
              },
              icon: Icons.graphic_eq,
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
          ? NoExistData(
              textCenter: 'No hay documentos registrados',
              onRefreshCallback: () async {
                ref
                    .watch(docActivitieProvider.notifier)
                    .loadNextPage(type: TypeFileOp.archive);
              },
              icon: Icons.graphic_eq,
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

// ============================================================
// HtmlContainerCustom - Renderiza HTML con WebView
// ============================================================
// HtmlContainerCustom - misma estructura que ContainerCustom (label + container plomo)
// pero el contenido se renderiza como HTML usando flutter_widget_from_html_core.
// ============================================================
class HtmlContainerCustom extends StatelessWidget {
  final String label;
  final String htmlData;

  const HtmlContainerCustom({
    super.key,
    required this.label,
    required this.htmlData,
  });

  @override
  Widget build(BuildContext context) {
    if (htmlData.trim().isEmpty) {
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
              overflow: TextOverflow.ellipsis,
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
            child: Align(
              alignment: Alignment.topLeft,
              child: HtmlWidget(
                htmlData,
                textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
                renderMode: RenderMode.column,
                customStylesBuilder: (element) {
                  // Forzar alineación a la izquierda para todos los elementos
                  return {'text-align': 'left'};
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ============================================================
// EmailDetailView - Detalle de correo con diseño plano (estilo Informacion)
// ============================================================
class EmailDetailView extends ConsumerStatefulWidget {
  final String activityId;

  const EmailDetailView({
    super.key,
    required this.activityId,
  });

  @override
  ConsumerState<EmailDetailView> createState() => _EmailDetailViewState();
}

class _EmailDetailViewState extends ConsumerState<EmailDetailView> {
  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityProvider(widget.activityId));
    final activity = activityState.activity;

    if (activityState.isLoading) {
      return const Scaffold(body: FullScreenLoader());
    }

    if (activity == null) {
      return const Scaffold(
        body: Center(
          child: Text('No se encontró información del correo.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: _buildInformacionTab(activity),
      ),
    );
  }

  Widget _buildInformacionTab(Activity activity) {
    final asunto = _resolveAsunto(activity);
    final bodyContent = _cleanHtmlContent(
      _resolveBodyContent(activity),
      asunto,
    );
    final attachments = activity.attachments ?? [];

    String contactoNombre = '';
    final lista = activity.actividadesContacto ?? [];
    if (lista.isNotEmpty) {
      contactoNombre = lista[0].contactoDesc ?? '';
    }

    final emailFrom = activity.emlsEmailFrom ?? '';
    final paraText = _formatRecipients(
        activity.toRecipients ?? [], activity.emlsEmailTo);
    final ccText = _formatRecipients(activity.ccRecipients ?? [], null);
    final bccText = _formatRecipients(activity.bccRecipients ?? [], null);

    final fecha = DateFormat('dd-MM-yyyy').format(activity.actiFechaActividad);
    final horaCompleta = activity.actiHoraActividad;
    String horaFormateada = '';
    try {
      horaFormateada = DateFormat('hh:mm a').format(
        DateFormat('HH:mm:ss').parse(
          horaCompleta.length >= 8 ? horaCompleta.substring(0, 8) : horaCompleta,
        ),
      );
    } catch (_) {
      horaFormateada = horaCompleta;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // -------- INFORMACIÓN --------
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'INFORMACIÓN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          ContainerCustom(label: 'Fecha', text: fecha),
          ContainerCustom(label: 'Hora', text: horaFormateada),

          // -------- REFERENCIAS --------
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'REFERENCIAS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          ContainerCustom(label: 'Empresa', text: activity.actiRazon ?? ''),
          ContainerCustom(label: 'Contacto', text: contactoNombre),
          ContainerCustom(
            label: 'Responsable',
            text: activity.actiNombreResponsable ?? '',
          ),

          // -------- DETALLE DEL CORREO --------
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'DETALLE DEL CORREO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          ContainerCustom(label: 'De', text: emailFrom),
          ContainerCustom(label: 'Para', text: paraText),
          ContainerCustom(label: 'CC', text: ccText),
          ContainerCustom(label: 'BCC', text: bccText),
          ContainerCustom(label: 'Asunto', text: asunto),

          // -------- CUERPO DEL CORREO (HTML renderizado) --------
          HtmlContainerCustom(
            label: 'Cuerpo del correo',
            htmlData: bodyContent,
          ),

          // -------- ADJUNTOS --------
          if (attachments.isNotEmpty) _buildAttachmentsSection(attachments),

          // -------- METADATOS --------
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'METADATOS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          ContainerCustom(label: 'Identificador', text: activity.id),
          ContainerCustom(
            label: 'Fecha de creación',
            text: DateFormat('dd/MM/yyyy HH:mm').format(activity.actiFechaActividad),
          ),
          ContainerCustom(
            label: 'Creado por',
            text: activity.actiNombreResponsable ?? '',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---- Adjuntos ----
  Widget _buildAttachmentsSection(List<EmailAttachment> attachments) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            'Adjuntos (${attachments.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 247, 245, 245),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: attachments.map((attachment) {
              return InkWell(
                onTap: () => _openAttachment(context, attachment),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(_iconForAttachment(attachment),
                          size: 28, color: const Color(0xFF0092c7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0092c7),
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatFileSize(attachment.size),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.download_rounded,
                          size: 22, color: Color(0xFF0092c7)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _iconForAttachment(EmailAttachment a) {
    final t = a.contentType.toLowerCase();
    final n = a.name.toLowerCase();
    if (t.contains('pdf') || n.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (t.contains('image') ||
        n.endsWith('.png') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.gif')) return Icons.image;
    if (t.contains('word') || n.endsWith('.doc') || n.endsWith('.docx')) {
      return Icons.description;
    }
    if (t.contains('excel') ||
        t.contains('spreadsheet') ||
        n.endsWith('.xls') ||
        n.endsWith('.xlsx')) return Icons.table_chart;
    if (t.contains('zip') || n.endsWith('.zip')) return Icons.folder_zip;
    if (t.contains('video') || n.endsWith('.mp4')) return Icons.videocam;
    if (t.contains('audio') || n.endsWith('.mp3') || n.endsWith('.wav')) {
      return Icons.audiotrack;
    }
    return Icons.attach_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _openAttachment(
      BuildContext context, EmailAttachment attachment) async {
    print('========== TAP ON ATTACHMENT ==========');
    print('Name: ${attachment.name}');
    print('ContentBytes length: ${attachment.contentBytes.length}');
    
    if (attachment.contentBytes.isEmpty) {
      print('ERROR: ContentBytes empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo no tiene contenido')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Abriendo archivo...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      print('Starting decode process in Isolate...');
      
      // Decodificar base64 en Isolate (NO bloquea UI)
      final bytes = await compute(_decodeBase64InIsolate, attachment.contentBytes);
      print('Decoded ${bytes.length} bytes');

      // Detectar extensión real desde bytes
      final realExt = _detectExtensionFromBytes(bytes);
      String fileName = attachment.name;
      if (realExt.isNotEmpty &&
          !fileName.toLowerCase().endsWith('.$realExt')) {
        final dot = fileName.lastIndexOf('.');
        if (dot > 0) fileName = fileName.substring(0, dot);
        fileName = '$fileName.$realExt';
      }

      // Guardar y abrir
      print('Getting temp directory...');
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      print('File path: $filePath');
      
      final file = File(filePath);
      print('Writing ${bytes.length} bytes to file...');
      await file.writeAsBytes(bytes);
      print('File written successfully');

      if (context.mounted) Navigator.of(context).pop();

      print('Opening file with OpenFile...');
      final result = await OpenFile.open(filePath);
      print('OpenFile result: type=${result.type}, message=${result.message}');
      
      if (result.type == ResultType.noAppToOpen && context.mounted) {
        // No hay app para abrir el archivo, mostrar opciones
        print('No app to open, showing options...');
        _showFileOptionsDialog(context, filePath, fileName);
      } else if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir: ${result.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _detectExtensionFromBytes(List<int> b) {
    if (b.length < 4) return '';
    if (b[0] == 0x25 && b[1] == 0x50 && b[2] == 0x44 && b[3] == 0x46) return 'pdf';
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'png';
    if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return 'jpg';
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return 'gif';
    if (b[0] == 0x50 && b[1] == 0x4B && b[2] == 0x03 && b[3] == 0x04) return 'zip';
    if (b[0] == 0xD0 && b[1] == 0xCF && b[2] == 0x11 && b[3] == 0xE0) return 'doc';
    return '';
  }

  // ---- Helpers ----
  String _formatRecipients(List<EmailRecipient> rec, String? fallback) {
    if (rec.isNotEmpty) {
      final first = rec.first;
      var text = first.name.isNotEmpty ? first.name : first.address;
      if (rec.length > 1) text += ' +${rec.length - 1}';
      return text;
    } else if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return '';
  }

  String _cleanHtmlContent(String html, String asunto) {
    if (html.isEmpty || asunto.isEmpty) return html;
    final escaped = RegExp.escape(asunto);
    final patterns = [
      RegExp(r'<h[1-6][^>]*>\s*' + escaped + r'\s*</h[1-6]>', caseSensitive: false),
      RegExp(r'<p[^>]*>\s*' + escaped + r'\s*</p>', caseSensitive: false),
      RegExp(r'<div[^>]*>\s*' + escaped + r'\s*</div>', caseSensitive: false),
      RegExp(r'<strong[^>]*>\s*' + escaped + r'\s*</strong>', caseSensitive: false),
      RegExp(r'<b[^>]*>\s*' + escaped + r'\s*</b>', caseSensitive: false),
    ];
    var cleaned = html;
    for (final p in patterns) {
      cleaned = cleaned.replaceFirst(p, '');
    }
    return cleaned;
  }

  String _resolveAsunto(Activity activity) {
    final emlsAsunto = (activity.emlsAsunto ?? '').trim();
    if (emlsAsunto.isNotEmpty) return emlsAsunto;
    final subject = (activity.subject ?? '').trim();
    if (subject.isNotEmpty) return subject;
    return 'Sin asunto';
  }

  String _resolveBodyContent(Activity activity) {
    final html = (activity.emailHtmlContent ?? '').trim();
    if (html.isNotEmpty) return html;
    final comentario = activity.actiComentario.trim();
    if (comentario.isNotEmpty) return comentario;
    return '<p>Sin contenido</p>';
  }

  void _showFileOptionsDialog(BuildContext context, String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No hay aplicación para abrir el archivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El archivo "$fileName" se guardó correctamente.'),
            const SizedBox(height: 16),
            const Text('¿Qué deseas hacer?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Abrir visor interno de PDF
              _openInternalPdfViewer(context, filePath, fileName);
            },
            child: const Text('Ver archivo'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Guardar en Descargas
              await _saveToDownloads(context, filePath, fileName);
            },
            child: const Text('Guardar en Descargas'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _openInternalPdfViewer(BuildContext context, String filePath, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PdfViewerScreen(
          filePath: filePath,
          fileName: fileName,
        ),
      ),
    );
  }

  Future<void> _saveToDownloads(BuildContext context, String sourcePath, String fileName) async {
    try {
      // Pedir permisos de almacenamiento
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se necesita permiso de almacenamiento')),
          );
        }
        return;
      }

      // Obtener directorio de descargas
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo acceder al almacenamiento')),
          );
        }
        return;
      }

      // Copiar archivo a Descargas
      final downloadsPath = '/storage/emulated/0/Download/$fileName';
      final sourceFile = File(sourcePath);
      await sourceFile.copy(downloadsPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo guardado en Descargas: $fileName'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error saving to downloads: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
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
            // const Divider(),
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
            // const Divider(),
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
            Visibility(
              visible: typeFileOp == TypeFileOp.photo,
              child: ListTile(
                title: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.camera),
                    SizedBox(width: 10),
                    Center(child: Text('Tomar Foto')),
                  ],
                ),
                // minTileHeight: 14,
                onTap: () async {
                  // Navigator.pop(modalContext);

                  // tabController.index = 1;

                  // context.push('/text_enlace');
                  // Navigator.pop(modalContext);

                  // tabController.index = 0;

                  final pickedFile =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  String? fileName;
                  String? filePath;
                  if (pickedFile != null) {
                    fileName = pickedFile.name;
                    filePath = pickedFile.path;
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

// ============================================================
// Función top-level para decodificar base64 en Isolate (NO bloquea UI)
// ============================================================
Uint8List _decodeBase64InIsolate(String base64String) {
  // Limpiar el base64
  String clean = base64String;
  if (clean.contains(',')) clean = clean.split(',').last;
  clean = clean.replaceAll(RegExp(r'\s+'), '');
  return base64Decode(clean);
}

// ============================================================
// Visor interno de PDF
// ============================================================
class _PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const _PdfViewerScreen({
    required this.filePath,
    required this.fileName,
  });

  @override
  State<_PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<_PdfViewerScreen> {
  int? totalPages;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  PDFViewController? _pdfController;

  Future<void> _goToPage(int delta) async {
    if (_pdfController == null || totalPages == null) return;
    final newPage = (currentPage + delta).clamp(0, totalPages! - 1);
    await _pdfController!.setPage(newPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00607D),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              size: 22,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.fileName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (isReady) ...[
            // Botón página anterior
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
              tooltip: 'Página anterior',
              onPressed: currentPage > 0 ? () => _goToPage(-1) : null,
            ),
            // Botón página siguiente
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              tooltip: 'Página siguiente',
              onPressed: (totalPages != null && currentPage < totalPages! - 1)
                  ? () => _goToPage(1)
                  : null,
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentPage + 1}/${totalPages ?? 0}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 56,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Error al cargar PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00607D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                PDFView(
                  filePath: widget.filePath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: false,
                  defaultPage: currentPage,
                  fitPolicy: FitPolicy.WIDTH,
                  fitEachPage: true,
                  preventLinkNavigation: false,
                  nightMode: false,
                  onViewCreated: (PDFViewController controller) {
                    _pdfController = controller;
                  },
                  onRender: (pages) {
                    setState(() {
                      totalPages = pages;
                      isReady = true;
                    });
                    print('PDF rendered: $pages pages');
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                    print('PDF error: $error');
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = 'Error en página $page: $error';
                    });
                    print('Page $page error: $error');
                  },
                  onPageChanged: (int? page, int? total) {
                    setState(() {
                      currentPage = page ?? 0;
                    });
                  },
                ),
                if (!isReady)
                  Container(
                    color: const Color(0xFFF5F7FA),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A8DD).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00A8DD),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Cargando documento...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00607D),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Esto puede tomar unos segundos',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      // Botones flotantes con colores corporativos
      floatingActionButton: isReady
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón ir al inicio
                FloatingActionButton.small(
                  heroTag: 'pdf_top',
                  backgroundColor: const Color(0xFF00A8DD),
                  elevation: 4,
                  onPressed: () async {
                    if (_pdfController != null) {
                      await _pdfController!.setPage(0);
                    }
                  },
                  child: const Icon(
                    Icons.vertical_align_top_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // Botón ir al final
                FloatingActionButton.small(
                  heroTag: 'pdf_bottom',
                  backgroundColor: const Color(0xFF00607D),
                  elevation: 4,
                  onPressed: () async {
                    if (_pdfController != null && totalPages != null) {
                      await _pdfController!.setPage(totalPages! - 1);
                    }
                  },
                  child: const Icon(
                    Icons.vertical_align_bottom_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

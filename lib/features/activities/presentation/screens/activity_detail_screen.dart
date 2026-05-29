import 'dart:convert';
import 'dart:io';

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
    _tabController = TabController(length: 5, vsync: this);
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
      length: 5,
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
                icon: Icon(Icons.email, size: 30),
                text: 'Info Prueba',
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
            buildEmailDetailView(),
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
                    maxLines: 10,
                    style: const TextStyle(
                        fontSize: 16, overflow: TextOverflow.ellipsis),
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
            child: HtmlWidget(
              htmlData,
              textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
              // Permite que el render se ajuste a la altura del contenido
              renderMode: RenderMode.column,
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
    final asunto = (activity.emlsAsunto?.isNotEmpty == true)
        ? activity.emlsAsunto!
        : (activity.subject ?? '');
    final bodyContent = _cleanHtmlContent(
      activity.emailHtmlContent ?? '',
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
    if (attachment.contentBytes.isEmpty) {
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
      // Limpiar base64
      String clean = attachment.contentBytes;
      if (clean.contains(',')) clean = clean.split(',').last;
      clean = clean.replaceAll(RegExp(r'\s+'), '');

      // Decodificar
      final bytes = base64Decode(clean);

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
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (context.mounted) Navigator.of(context).pop();

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
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

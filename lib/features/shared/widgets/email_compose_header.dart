import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/config/theme/app_theme.dart';
import 'package:crm_app/features/shared/infrastructure/services/notification_service.dart';
import 'package:image_picker/image_picker.dart';

// Widget separado para mostrar archivos adjuntos en el área scrollable
class EmailAttachedFilesList extends StatelessWidget {
  final List<PlatformFile> attachedFiles;
  final ValueChanged<List<PlatformFile>> onRemoveFile;

  const EmailAttachedFilesList({
    super.key,
    required this.attachedFiles,
    required this.onRemoveFile,
  });

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (attachedFiles.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.attach_file_rounded, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${attachedFiles.length} archivo${attachedFiles.length > 1 ? 's' : ''} adjunto${attachedFiles.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          ...attachedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            final extension = file.name.split('.').last.toUpperCase();
            final sizeKB = (file.size != null && file.size! > 0) 
                ? (file.size! / 1024).toStringAsFixed(1) 
                : '?';
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < attachedFiles.length - 1 ? 8 : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getFileColor(extension),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        _getFileIcon(extension),
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$extension • $sizeKB KB',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        final updatedFiles = List<PlatformFile>.from(attachedFiles);
                        updatedFiles.removeAt(index);
                        onRemoveFile(updatedFiles);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class EmailComposeHeader extends StatefulWidget {
  final VoidCallback onLogout;
  final Future<void> Function(List<PlatformFile> files) onSend;
  final List<PlatformFile> attachedFiles;
  final ValueChanged<List<PlatformFile>> onAddFiles;
  const EmailComposeHeader({
    super.key,
    required this.onLogout,
    required this.onSend,
    required this.attachedFiles,
    required this.onAddFiles,
  });

  @override
  State<EmailComposeHeader> createState() => _EmailComposeHeaderState();
}

class _EmailComposeHeaderState extends State<EmailComposeHeader> {
  final GlobalKey _attachButtonKey = GlobalKey();

  void _showAttachmentOptions() {
    final RenderBox renderBox = _attachButtonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + 200,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      color: Colors.white,
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              _pickDocument();
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A8DD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file_rounded,
                      size: 20,
                      color: Color(0xFF00A8DD),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subir documento',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'PDF, DOC, DOCX',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A8DD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_rounded,
                      size: 20,
                      color: Color(0xFF00A8DD),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añadir imagen',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'JPG, PNG, GIF',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final validFiles = result.files.where((f) => f.path != null).toList();
    final updatedFiles = [...widget.attachedFiles, ...validFiles];
    widget.onAddFiles(updatedFiles);
    
    if (!mounted) return;
    NotificationService().showInfo(
      context: context,
      title: 'Archivos adjuntados',
      message: '${validFiles.length} archivo(s) agregado(s)',
      duration: 3000,
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // OPTIMIZACIÓN: Comprimir imágenes al seleccionarlas para reducir tiempo de subida
    // maxWidth: 1920 (Full HD) - suficiente para correo
    // imageQuality: 85 - buena calidad pero archivos ~70% más pequeños
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (!mounted || images.isEmpty) return;

    // Convertir XFile a PlatformFile (el tamaño se obtendrá después si es necesario)
    final List<PlatformFile> imagePlatformFiles = images
        .map((image) => PlatformFile(
              path: image.path,
              name: image.name,
              size: 0, // FilePicker lo calculará automáticamente al enviar
            ))
        .toList();

    final updatedFiles = [...widget.attachedFiles, ...imagePlatformFiles];
    widget.onAddFiles(updatedFiles);

    if (!mounted) return;
    NotificationService().showInfo(
      context: context,
      title: 'Imágenes adjuntadas',
      message: '${images.length} imagen(es) agregada(s)',
      duration: 3000,
    );
  }

  Future<void> _sendEmail() async {
    await widget.onSend(List<PlatformFile>.from(widget.attachedFiles));
  }

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nuevo correo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    key: _attachButtonKey,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      onPressed: _showAttachmentOptions,
                      icon: Icon(Icons.attach_file_rounded, color: Colors.grey.shade700),
                      tooltip: 'Adjuntar',
                      iconSize: 22,
                    ),
                  ),
                  if (widget.attachedFiles.isNotEmpty)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.attachedFiles.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async => _sendEmail(),
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  tooltip: 'Enviar',
                  iconSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

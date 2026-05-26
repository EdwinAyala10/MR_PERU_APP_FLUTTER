import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/config/theme/app_theme.dart';
import 'package:crm_app/features/shared/infrastructure/services/notification_service.dart';

class EmailComposeHeader extends StatefulWidget {
  final VoidCallback onLogout;
  final Future<void> Function(List<PlatformFile> files) onSend;
  const EmailComposeHeader({super.key, required this.onLogout, required this.onSend});

  @override
  State<EmailComposeHeader> createState() => _EmailComposeHeaderState();
}

class _EmailComposeHeaderState extends State<EmailComposeHeader> {
  final List<PlatformFile> _attachedFiles = [];

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    setState(() {
      _attachedFiles.addAll(result.files.where((f) => f.path != null));
    });
    
    if (!mounted) return;
    NotificationService().showInfo(
      context: context,
      title: 'Archivos adjuntados',
      message: '${_attachedFiles.length} archivo(s) agregado(s) al correo',
      duration: 3000,
    );
  }

  Future<void> _sendEmail() async {
    await widget.onSend(List<PlatformFile>.from(_attachedFiles));
    if (!mounted) return;
    setState(() {
      _attachedFiles.clear();
    });
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  onPressed: _pickDocument,
                  icon: Icon(Icons.attach_file_rounded, color: Colors.grey.shade700),
                  tooltip: 'Adjuntar archivo',
                  iconSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.description_outlined, color: Colors.grey.shade700),
                  tooltip: 'Plantilla',
                  iconSize: 22,
                ),
              ),
              const SizedBox(width: 12),
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
          if (_attachedFiles.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                     child: Text(
                       _attachedFiles.map((f) => f.name).join(', '),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  IconButton(
                     onPressed: () {
                       setState(() {
                         _attachedFiles.clear();
                       });
                     },
                    icon: Icon(Icons.close_rounded, size: 20, color: Colors.grey.shade600),
                    tooltip: 'Quitar adjunto',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

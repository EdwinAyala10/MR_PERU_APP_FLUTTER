import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adjuntos: ${_attachedFiles.length} archivo(s)')),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await KeyValueStorageServiceImpl().removeKey('microsoft_synced');
                  widget.onLogout();
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Enviar correo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF00607D),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF00607D)),
                  tooltip: 'Adjuntar archivo',
                  iconSize: 22,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.description_outlined, color: Color(0xFF00607D)),
                  tooltip: 'Plantilla',
                  iconSize: 22,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8DD),
                  borderRadius: BorderRadius.circular(8),
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
                color: const Color(0xFF00A8DD).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00A8DD).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A8DD).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file_outlined,
                      size: 18,
                      color: Color(0xFF00607D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                     child: Text(
                       _attachedFiles.map((f) => f.name).join(', '),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF00607D),
                      ),
                    ),
                  ),
                  IconButton(
                     onPressed: () {
                       setState(() {
                         _attachedFiles.clear();
                       });
                     },
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Quitar adjunto',
                    color: const Color(0xFF6B7280),
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

import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EmailComposeHeader extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onSend;
  const EmailComposeHeader({super.key, required this.onLogout, required this.onSend});

  @override
  State<EmailComposeHeader> createState() => _EmailComposeHeaderState();
}

class _EmailComposeHeaderState extends State<EmailComposeHeader> {
  String? _attachedFileName;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final fileName = result.files.single.name;
    setState(() {
      _attachedFileName = fileName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Archivo adjuntado: $fileName')),
    );
  }

  void _sendEmail() {
    setState(() {
      _attachedFileName = null;
    });
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await KeyValueStorageServiceImpl().removeKey('microsoft_synced');
                  widget.onLogout();
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Cerrar sesion'),
              ),
              const Expanded(
                child: Center(
                  child: Text('Enviar correo', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              IconButton(onPressed: _pickDocument, icon: const Icon(Icons.attach_file)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.description_outlined)),
              IconButton(onPressed: _sendEmail, icon: const Icon(Icons.send, color: Colors.blue)),
            ],
          ),
          if (_attachedFileName != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _attachedFileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _attachedFileName = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Quitar adjunto',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

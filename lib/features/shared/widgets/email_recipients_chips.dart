import 'package:flutter/material.dart';
import 'package:crm_app/config/theme/app_theme.dart';
import 'package:crm_app/features/shared/infrastructure/services/notification_service.dart';

class EmailRecipientData {
  final String name;
  final String email;
  final bool isRemovable;

  EmailRecipientData({
    required this.name,
    required this.email,
    this.isRemovable = true,
  });
}

class EmailRecipientsChips extends StatefulWidget {
  final String label;
  final String hint;
  final List<EmailRecipientData> recipients;
  final Function(EmailRecipientData) onAdd;
  final Function(int) onRemove;
  final Color chipColor;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const EmailRecipientsChips({
    super.key,
    required this.label,
    required this.hint,
    required this.recipients,
    required this.onAdd,
    required this.onRemove,
    this.chipColor = const Color(0xFF00A8DD),
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  State<EmailRecipientsChips> createState() => _EmailRecipientsChipsState();
}

class _EmailRecipientsChipsState extends State<EmailRecipientsChips> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addEmailFromField() {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) return;
    
    // Validación completa de formato de email
    if (!_isValidEmail(email)) {
      NotificationService().showError(
        context: context,
        title: 'Formato de correo inválido',
        message: 'Por favor ingresa un correo válido (ejemplo: usuario@dominio.com)',
      );
      return;
    }

    // Agregar destinatario con email como name y address
    widget.onAdd(EmailRecipientData(
      name: email,
      email: email,
    ));
    
    // Limpiar el campo
    _emailController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con label y toggle
          InkWell(
            onTap: widget.onToggle,
            child: Row(
              children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: widget.chipColor,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: widget.chipColor,
                ),
              ),
                if (widget.recipients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '(${widget.recipients.length})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                if (widget.onToggle != null) ...[
                  const Spacer(),
                  Icon(
                    widget.isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ],
            ),
          ),
          
          if (widget.isExpanded) ...[
            const SizedBox(height: 10),
            
            // Campo de entrada de email directo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips existentes
                  if (widget.recipients.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.recipients.asMap().entries.map((entry) {
                        final index = entry.key;
                        final recipient = entry.value;
                        return _buildRecipientChip(recipient, index);
                      }).toList(),
                    ),
                  
                  // Campo de texto para escribir email directamente
                  TextField(
                    controller: _emailController,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => _addEmailFromField(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipientChip(EmailRecipientData recipient, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.chipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de lock si no es removible
          if (!recipient.isRemovable)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.lock_outline,
                size: 12,
                color: widget.chipColor,
              ),
            ),
          
          // Email en el chip
          Flexible(
            child: Tooltip(
              message: recipient.email,
              child: Text(
                recipient.email,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.chipColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Botón eliminar
          if (recipient.isRemovable) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: () => widget.onRemove(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: widget.chipColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: widget.chipColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }



  /// Validación de formato de correo electrónico
  bool _isValidEmail(String email) {
    // Regex completo para validar formato de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    
    // Verificar formato básico
    if (!emailRegex.hasMatch(email)) {
      return false;
    }
    
    // Validaciones adicionales
    final parts = email.split('@');
    if (parts.length != 2) return false;
    
    final localPart = parts[0];
    final domainPart = parts[1];
    
    // La parte local no puede estar vacía ni empezar/terminar con punto
    if (localPart.isEmpty || localPart.startsWith('.') || localPart.endsWith('.')) {
      return false;
    }
    
    // La parte del dominio debe tener al menos un punto
    if (!domainPart.contains('.')) {
      return false;
    }
    
    // El dominio no puede empezar o terminar con punto o guión
    if (domainPart.startsWith('.') || domainPart.endsWith('.') ||
        domainPart.startsWith('-') || domainPart.endsWith('-')) {
      return false;
    }
    
    return true;
  }
}

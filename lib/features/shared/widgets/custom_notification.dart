import 'package:flutter/material.dart';
import 'package:crm_app/config/theme/app_theme.dart';
import 'package:crm_app/features/shared/domain/enums/notification_type.dart';

class NotificationConfig {
  final IconData icon;
  final Color color;
  
  const NotificationConfig({
    required this.icon,
    required this.color,
  });
}

class CustomNotification extends StatelessWidget {
  final String title;
  final String message;
  final NotificationType type;
  final VoidCallback? onDismiss;
  
  const CustomNotification({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onDismiss,
  });
  
  NotificationConfig _getConfig() {
    switch (type) {
      case NotificationType.success:
        return NotificationConfig(
          icon: Icons.check_circle_rounded,
          color: primaryColor,
        );
      case NotificationType.error:
        return NotificationConfig(
          icon: Icons.error_rounded,
          color: Colors.red.shade600,
        );
      case NotificationType.info:
        return NotificationConfig(
          icon: Icons.info_rounded,
          color: Colors.blue.shade600,
        );
      case NotificationType.warning:
        return NotificationConfig(
          icon: Icons.warning_rounded,
          color: Colors.orange.shade600,
        );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final width = MediaQuery.of(context).size.width;
    final notificationWidth = width > 600 ? 400.0 : width * 0.9;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        width: notificationWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: config.color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                color: config.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Botón cerrar
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: secondaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

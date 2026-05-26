import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crm_app/features/shared/domain/enums/notification_type.dart';
import 'package:crm_app/features/shared/widgets/custom_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();
  
  OverlayEntry? _overlayEntry;
  Timer? _timer;
  
  void showSuccess({
    required BuildContext context,
    required String title,
    String message = '',
    int duration = 4000,
  }) {
    _show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.success,
      duration: duration,
    );
  }
  
  void showError({
    required BuildContext context,
    required String title,
    String message = '',
    int duration = 6000,
  }) {
    _show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.error,
      duration: duration,
    );
  }
  
  void showInfo({
    required BuildContext context,
    required String title,
    String message = '',
    int duration = 3000,
  }) {
    _show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.info,
      duration: duration,
    );
  }
  
  void showWarning({
    required BuildContext context,
    required String title,
    String message = '',
    int duration = 5000,
  }) {
    _show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.warning,
      duration: duration,
    );
  }
  
  void _show({
    required BuildContext context,
    required String title,
    required String message,
    required NotificationType type,
    required int duration,
  }) {
    // Dismiss previous notification if exists
    _dismiss();
    
    final width = MediaQuery.of(context).size.width;
    final rightMargin = width > 600 ? 16.0 : width * 0.05;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWrapper(
        title: title,
        message: message,
        type: type,
        rightMargin: rightMargin,
        onDismiss: _dismiss,
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    
    // Auto dismiss after duration
    _timer = Timer(Duration(milliseconds: duration), _dismiss);
  }
  
  void _dismiss() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _timer = null;
  }
}

class _NotificationWrapper extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final double rightMargin;
  final VoidCallback onDismiss;
  
  const _NotificationWrapper({
    required this.title,
    required this.message,
    required this.type,
    required this.rightMargin,
    required this.onDismiss,
  });
  
  @override
  State<_NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<_NotificationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleDismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    
    // Posicionar debajo del sistema (status bar + 16px de margen)
    final topPosition = topPadding + 16.0;
    
    return Positioned(
      top: topPosition,
      right: widget.rightMargin,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomNotification(
            title: widget.title,
            message: widget.message,
            type: widget.type,
            onDismiss: _handleDismiss,
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/services.dart';

import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../firebase_options.dart';
import '../../../../local_notifications/local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final user = ref.watch(authProvider).user;

  final updateDeviceCallback =
      ref.read(authProvider.notifier).updateTokenDevice;

  //final authRepository = AuthRepositoryImpl();
  return NotificationsNotifier(
    user: user!,
    onUpdateDeviceCallback: updateDeviceCallback,
  );
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  User user;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final Future<bool> Function(String tokenDevice)? onUpdateDeviceCallback;

  NotificationsNotifier({required this.user, this.onUpdateDeviceCallback})
      : super(NotificationsState()) {
    _initialStatusCheck();
    _onForegroundMessage();
  }

  void onChangeStatus(AuthorizationStatus status) {
    state = state.copyWith(status: status);
  }

  static Future<void> initialFCM() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    await LocalNotifications.requestPermissionLocalNotifications();

    notificationStatusChanged(settings.authorizationStatus);
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();

    
    notificationStatusChanged(settings.authorizationStatus);
  }

  void _handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    LocalNotifications.showLocalNotification(
      id: 1, 
      body: message.notification!.body ?? '',
      title: message.notification!.title ?? '',
      data: message.data.toString()
    );
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
  }

  void _getFCMToken() async {
    try {
      final settings = await messaging.getNotificationSettings();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        log('Notificaciones no autorizadas');
        return;
      }

      final token = await messaging.getToken();
      if (token == null) {
        log('No se pudo obtener el token de FCM');
        return;
      }

      log('Token de FCM: $token');
      // Guardar Token Device
      await onUpdateDeviceCallback!(token);
    } on PlatformException catch (e) {
      log('Error al obtener el token de FCM: ${e.message}');
      log('Detalles del error: ${e.details}');
      // Manejar el error adecuadamente
    } catch (e) {
      log('Error inesperado al obtener el token de FCM: $e');
    }
  }

  void notificationStatusChanged(AuthorizationStatus status) {
    state = state.copyWith(status: status);
    _getFCMToken();
  }
}

class NotificationsState {
  final AuthorizationStatus status;

  NotificationsState({this.status = AuthorizationStatus.notDetermined});

  NotificationsState copyWith({
    AuthorizationStatus? status,
  }) =>
      NotificationsState(status: status ?? this.status);
}

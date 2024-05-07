import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/firebase_options.dart';
import 'package:crm_app/local_notifications/local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
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
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification == null) return;

    LocalNotifications.showLocalNotification(
      id: 1, 
      body: message.notification!.body ?? '',
      title: message.notification!.title ?? '',
      data: message.data.toString()
    );

    print('Message also contained a notification: ${message.notification}');
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
  }

  void _getFCMToken() async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();

    print('token: ${token}');

    //Guardar Token Device
    await onUpdateDeviceCallback!(token!);
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

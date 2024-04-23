import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final user = ref.watch(authProvider).user;

  //final authRepository = AuthRepositoryImpl();
  return NotificationsNotifier(user: user!);
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  User user;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsNotifier({required this.user}) : super(NotificationsState()) {}

  void onChangeStatus(AuthorizationStatus status) {
    state = state.copyWith(status: status);
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

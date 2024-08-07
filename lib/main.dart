import 'config/config.dart';
import 'features/shared/presentation/providers/notifications_provider.dart';
import 'local_notifications/local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationsNotifier.initialFCM();

  //TODO: DESCOMENTAR NOTIFICACIONES PUSH
  await LocalNotifications.initializeLocalNotifications();

  await Environment.initEnvironment();

  initializeDateFormatting('es_ES', null)
      .then((_) => {runApp(const ProviderScope(child: MainApp()))});
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

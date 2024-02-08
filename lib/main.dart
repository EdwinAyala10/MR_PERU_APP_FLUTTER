import 'package:crm_app/config/config.dart';
import 'package:crm_app/config/router/app_router.dart';
import 'package:crm_app/features/auth/auth.dart';
import 'package:crm_app/features/companies/companies.dart';
import 'package:crm_app/features/companies/presentation/screens/companies_screen.dart';
import 'package:crm_app/features/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {

  runApp(
    const ProviderScope(child: MainApp())
  );
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/companies',
      builder: (context, state) => const CompaniesScreen(),
    ),
    GoRoute(
      path: '/company',
      builder: (context, state) => const CompanyScreen(),
    ),
  ],
);


class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //final appRouter = ref.watch( goRouterProvider );

    return MaterialApp.router(
      theme: AppTheme().getTheme(),
      //routerConfig: appRouter,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

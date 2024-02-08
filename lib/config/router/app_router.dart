import 'package:crm_app/features/companies/companies.dart';
import 'package:crm_app/features/dashboard/dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/auth/auth.dart';

//import 'app_router_notifier.dart';

final goRouterProvider = Provider((ref) {

  //final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    //refreshListenable: goRouterNotifier,
    routes: [
      ///* Primera pantalla
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),

      ///* Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      ///* Dash Routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      ///* Company Routes
      GoRoute(
        path: '/companies',
        builder: (context, state) => const CompaniesScreen(),
      ),

      GoRoute(
        path: '/company/:id', // /product/new
        builder: (context, state) => const CompanyScreen(),
      ),
    ],
    
  );
});

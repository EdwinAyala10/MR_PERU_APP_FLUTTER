import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/activities/presentation/screens/activities_screen.dart';
import 'package:crm_app/features/activities/presentation/screens/activity_screen.dart';
import 'package:crm_app/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:crm_app/features/agenda/presentation/screens/event_screen.dart';
import 'package:crm_app/features/auth/auth.dart';
import 'package:crm_app/features/companies/companies.dart';
import 'package:crm_app/features/contacts/presentation/screens/contact_screen.dart';
import 'package:crm_app/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:crm_app/features/dashboard/dashboard.dart';
import 'package:crm_app/features/documents/documents.dart';
import 'package:crm_app/features/opportunities/presentation/screens/opportunities_screen.dart';
import 'package:crm_app/features/opportunities/presentation/screens/opportunity_screen.dart';
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
    
    GoRoute(
      path: '/contacts',
      builder: (context, state) => const ContactsScreen(),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),

    GoRoute(
      path: '/opportunities',
      builder: (context, state) => const OpportunitiesScreen(),
    ),
    GoRoute(
      path: '/opportunity',
      builder: (context, state) => const OpportunityScreen(),
    ),

    GoRoute(
      path: '/activities',
      builder: (context, state) => const ActivitiesScreen(),
    ),
    GoRoute(
      path: '/activity',
      builder: (context, state) => const ActivityScreen(),
    ),
    GoRoute(
      path: '/agenda',
      builder: (context, state) => const AgendaScreen(),
    ),
    GoRoute(
      path: '/event',
      builder: (context, state) => const EventScreen(),
    ),
    GoRoute(
      path: '/documents',
      builder: (context, state) => const DocumentsScreen(),
    ),
    GoRoute(
      path: '/document',
      builder: (context, state) => const DocumentScreen (),
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

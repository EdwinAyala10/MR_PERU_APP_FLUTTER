import 'package:crm_app/features/activities/presentation/screens/activities_screen.dart';
import 'package:crm_app/features/activities/presentation/screens/activity_screen.dart';
import 'package:crm_app/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:crm_app/features/agenda/presentation/screens/event_screen.dart';
import 'package:crm_app/features/companies/companies.dart';
import 'package:crm_app/features/companies/presentation/screens/company_check_in_screen.dart';
import 'package:crm_app/features/companies/presentation/screens/company_detail_screen.dart';
import 'package:crm_app/features/companies/presentation/screens/company_local_screen.dart';
import 'package:crm_app/features/contacts/contacts.dart';
import 'package:crm_app/features/dashboard/dashboard.dart';
import 'package:crm_app/features/documents/documents.dart';
import 'package:crm_app/features/kpis/kpis.dart';
import 'package:crm_app/features/opportunities/presentation/screens/opportunities_screen.dart';
import 'package:crm_app/features/opportunities/presentation/screens/opportunity_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crm_app/features/auth/auth.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';

import 'app_router_notifier.dart';

final goRouterProvider = Provider((ref) {

  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: goRouterNotifier,
    routes: [
      ///* Primera pantalla
      /*GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),*/

      ///* Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      ///* Dashboard Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      ///* Activities Routes
      GoRoute(
        path: '/activities',
        builder: (context, state) => const ActivitiesScreen(),
      ),
      GoRoute(
        path: '/activity/:id', // /activity/new
        builder: (context,GoRouterState state) => ActivityScreen(
          activityId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      ///* Agenda Routes
      GoRoute(
        path: '/agenda',
        builder: (context, state) => const AgendaScreen(),
      ),

      GoRoute(
        path: '/kpis',
        builder: (context, state) => const KpisScreen(),
      ),

      GoRoute(
        path: '/kpi/:id', // /event/new
        builder: (context, state) => KpiScreen(
          kpiId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      GoRoute(
        path: '/event/:id', // /event/new
        builder: (context, state) => EventScreen(
          eventId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      ///* Companies Routes
      GoRoute(
        path: '/companies',
        builder: (context, state) => const CompaniesScreen(),
      ),
      GoRoute(
        path: '/company_detail/:id', // /company/new
        builder: (context, state) => CompanyDetailScreen(
          companyId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),
      GoRoute(
        path: '/company/:rucId', // /company/new
        builder: (context, state) => CompanyScreen(
          rucId: state.pathParameters['rucId'] ?? 'no-id',
        ),
      ),
      GoRoute(
        path: '/company_local/:id', // /company/new
        builder: (context, state) => CompanyLocalScreen(
          id: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      GoRoute(
        path: '/company_check_in/:id', // /company/new
        builder: (context, state) => CompanyCheckInScreen(
          id: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      ///* Contacts Routes
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/contact/:id', // /contact/new
        builder: (context, state) => ContactScreen(
          contactId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      ///* Documents Routes
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/document/:id', // /document/new
        builder: (context, state) => DocumentScreen(
          documentId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      ///* Opportunities Routes
      GoRoute(
        path: '/opportunities',
        builder: (context, state) => const OpportunitiesScreen(),
      ),
      GoRoute(
        path: '/opportunity/:id', // /contact/new
        builder: (context, state) => OpportunityScreen(
          opportunityId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

    ],

    redirect: (context, state) {
      
      final isGoingTo = state.matchedLocation;
      final authStatus = goRouterNotifier.authStatus;

      if ( isGoingTo == '/splash' && authStatus == AuthStatus.checking ) return null;

      if ( authStatus == AuthStatus.notAuthenticated ) {
        if ( isGoingTo == '/login' ) return null;

        return '/login';
      }

      if ( authStatus == AuthStatus.authenticated ) {
        if ( isGoingTo == '/login' || isGoingTo == '/splash' ){
           return '/';
        }
      }


      return null;
    },
  );
});

import 'package:crm_app/features/documents/presentation/screens/enlace_screen.dart';
import 'package:crm_app/features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import 'package:crm_app/features/route-planner/presentation/screens/register_route_planner_screen.dart';
import 'package:crm_app/features/route-planner/presentation/screens/route_day_screen.dart';
import 'package:crm_app/features/route-planner/presentation/screens/route_planner_screen.dart';

import '../../features/activities/presentation/screens/activity_detail_screen.dart';
import '../../features/activities/presentation/screens/activity_screen_post_call.dart';
import '../../features/contacts/presentation/screens/contact_detail_screen.dart';
import '../../features/indicators/indicators.dart';
import '../../features/location/presentation/screens/map_screen.dart';
import '../../features/location/presentation/screens/view_map_screen.dart';
import '../../features/shared/presentation/screens/send_whatsapp_screen.dart';
import '../../features/shared/presentation/screens/text_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/activities/presentation/screens/screens.dart';
import '../../features/agenda/presentation/screens/screens.dart';
import '../../features/companies/companies.dart';
import '../../features/contacts/contacts.dart';
import '../../features/dashboard/dashboard.dart';
import '../../features/documents/documents.dart';
import '../../features/kpis/kpis.dart';
import '../../features/opportunities/presentation/screens/screens.dart';
import '../../features/auth/auth.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import 'app_router_notifier.dart';

final goRouterProvider = Provider((ref) {

  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
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
      GoRoute(
        path: '/activity_detail/:id', // /activity/new
        builder: (context,GoRouterState state) => ActivityDetailScreen(
          activityId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      GoRoute(
        path: '/text', // /activity/new
        builder: (context,GoRouterState state) => const TextScreen(),
      ),

      GoRoute(
        path: '/send_whatsapp', // /activity/new
        builder: (context,GoRouterState state) => const SendWhatsappScreen(),
      ),

      GoRoute(
        path: '/text_enlace', // /activity/new
        builder: (context,GoRouterState state) => const EnlaceScreen(),
      ),

      GoRoute(
        path: '/activity_post_call/:id/:phone', // /activity/new
        builder: (context,GoRouterState state) => ActivityPostCallScreen(
          contactId: state.pathParameters['id'] ?? 'no-id',
          phone: state.pathParameters['phone'] ?? 'no-phone',
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
        path: '/route_planner',
        builder: (context, state) => const RoutePlannerScreen(),
      ),
      GoRoute(
        path: '/register_route_planner',
        builder: (context, state) => const RegisterRoutePlannerScreen(),
      ),
      GoRoute(
        path: '/route_day_planner',
        builder: (context, state) => RouteDayScreen(),
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
        path: '/company_map/:rucId/:identificator', // /company/new
        builder: (context, state) => CompanyMapScreen(
          rucId: state.pathParameters['rucId'] ?? 'no-id',
          identificator: state.pathParameters['identificator'] ?? 'no-key',
        ),
      ),
      GoRoute(
        path: '/map', // /company/new
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/view-map/:coors', // /company/new
        builder: (context, state) => ViewMapScreen(
          coors: state.pathParameters['coors'] ?? '',
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

      GoRoute(
        path: '/contact_detail/:id', // /contact/new
        builder: (context, state) => ContactDetailScreen(
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
      GoRoute(
        path: '/opportunity_detail/:id', // /opportunity/new
        builder: (context, state) => OpportunityDetailScreen(
          opportunityId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),

      GoRoute(
        path: '/indicators',
        builder: (context, state) => const IndicatorsScreen(),
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

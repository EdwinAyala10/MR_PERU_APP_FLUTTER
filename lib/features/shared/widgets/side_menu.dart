import '../../auth/presentation/providers/auth_provider.dart';
import '../shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});

  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;

    final user = ref.read(authProvider.notifier).state.user;

    return NavigationDrawer(
        elevation: 1,
        selectedIndex: navDrawerIndex,
        onDestinationSelected: (value) {
          setState(() {
            navDrawerIndex = value;
          });

          //final menuItem = appMenuItems[value];

          switch (value) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/companies');
              break;
            case 2:
              context.go('/contacts');
              break;
            case 3:
              context.go('/opportunities');
              break;
            case 4:
              context.go('/activities');
              break;
            case 5:
              context.go('/agenda');
              break;
            case 6:
              //context.go('/kpis');
              context.go('/kpi/new');
              break;
            case 7:
              //context.go('/documents');
              context.go('/indicators');
              break;
            default:
              context.go('/dashboard');
          }

          //context.push( menuItem.link );
          widget.scaffoldKey.currentState?.closeDrawer();
        },
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, hasNotch ? 0 : 20, 16, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).hintColor,
                    child: Text(
                      user?.name.substring(0, 1) ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Hola, ${user?.name ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: Text('Dashboard'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.account_balance_rounded),
            label: Text('Empresas'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.perm_contact_cal),
            label: Text('Contactos'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.work),
            label: Text('Oportunidades'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.local_activity_outlined),
            label: Text('Actividades'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.calendar_month),
            label: Text('Calendario'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.task),
            label: Text('Objectivos'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.auto_graph_outlined),
            label: Text('Indicadores'),
          ),
          /*const NavigationDrawerDestination(
            icon: Icon(Icons.document_scanner_sharp),
            label: Text('Documentos'),
          ),*/
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomFilledButton(
                onPressed: () {
                  //context.push('/login');
                  ref.read(authProvider.notifier).logout();
                },
                text: 'Cerrar sesión'),
          ),
        ]);
  }
}

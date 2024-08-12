import 'package:flutter/widgets.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _NavigationItem {
  final int id;
  final IconData icon;
  final String label;
  final String url;

  _NavigationItem({required this.id, required this.icon, required this.label, required this.url});
}

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});

  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;
  
  final List<_NavigationItem>  _navigationItemsOther =[
    _NavigationItem(id: 0, icon: Icons.dashboard_outlined, label: 'Dashboard', url: '/dashboard' ),
    _NavigationItem(id: 1, icon: Icons.account_balance_rounded, label: 'Empresas', url: '/companies' ),
    _NavigationItem(id: 2, icon: Icons.perm_contact_cal, label: 'Contactos', url: '/contacts' ),
    _NavigationItem(id: 3, icon: Icons.work, label: 'Oportunidades', url: '/opportunities' ),
    _NavigationItem(id: 4, icon: Icons.local_activity_outlined, label: 'Actividades', url: '/activities' ),
    _NavigationItem(id: 5, icon: Icons.calendar_month, label: 'Eventos', url: '/agenda' ),
    _NavigationItem(id: 6, icon: Icons.document_scanner_sharp, label: 'Documentos', url: '/documents' ),
  ];

  final List<_NavigationItem> _navigationItemsAdmin = [
    _NavigationItem(id: 0, icon: Icons.dashboard_outlined, label: 'Dashboard', url: '/dashboard' ),
    _NavigationItem(id: 1, icon: Icons.account_balance_rounded, label: 'Empresas', url: '/companies' ),
    _NavigationItem(id: 2, icon: Icons.map_outlined, label: 'Planificar de rutas', url: '/route_planner' ),
    _NavigationItem(id: 3, icon: Icons.perm_contact_cal, label: 'Contactos', url: '/contacts' ),
    _NavigationItem(id: 4, icon: Icons.work, label: 'Oportunidades', url: '/opportunities' ),
    _NavigationItem(id: 5, icon: Icons.local_activity_outlined, label: 'Actividades', url: '/activities' ),
    _NavigationItem(id: 6, icon: Icons.calendar_month, label: 'Eventos', url: '/agenda' ),
    _NavigationItem(id: 7, icon: Icons.task, label: 'Objetivos', url: '/kpi/new' ),
    _NavigationItem(id: 8, icon: Icons.auto_graph_outlined, label: 'Indicadores', url: '/indicators' ),
    _NavigationItem(id: 9, icon: Icons.document_scanner_sharp, label: 'Documentos', url: '/documents' ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;

    final user = ref.watch(authProvider).user;

    final isAdmin = user!.isAdmin;

    return NavigationDrawer(
        elevation: 1,
        selectedIndex: navDrawerIndex,
        onDestinationSelected: (value) {

          print('value IMPRIMIR: ${value}');

          setState(() {
            navDrawerIndex = value;
          });

          //final menuItem = appMenuItems[value];
          if (isAdmin) {
            context.go(_navigationItemsAdmin[navDrawerIndex].url);
          } else {
            context.go(_navigationItemsOther[navDrawerIndex].url);
          }
          
          /*switch (value) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/companies');
              break;
            case 2:
              context.go('/route_planner');
              break;
            case 3:
              context.go('/contacts');
              break;
            case 4:
              context.go('/opportunities');
              break;
            case 5:
              context.go('/activities');
              break;
            case 6:
              context.go('/agenda');
              break;
            case 7:
              context.go('/kpi/new');
              break;
            case 8:
              context.go('/indicators');
              break;
            case 9:
              context.go('/documents');
              break;
            default:
              context.go('/dashboard');
          }*/

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

          if (isAdmin) 
            ..._navigationItemsAdmin.map((item) {
              return NavigationDrawerDestination(
                icon: Icon(item.icon),
                label: Text(item.label),
              );
            }).toList(),

          if (!isAdmin) 
            ..._navigationItemsOther.map((item) {
              return NavigationDrawerDestination(
                icon: Icon(item.icon),
                label: Text(item.label),
              );
            }).toList(),

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

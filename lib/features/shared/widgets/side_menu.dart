import 'package:crm_app/features/shared/shared.dart';
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
    final textStyles = Theme.of(context).textTheme;

    return NavigationDrawer(
        elevation: 1,
        selectedIndex: navDrawerIndex,
        onDestinationSelected: (value) {
          setState(() {
            navDrawerIndex = value;
          });

          //final menuItem = appMenuItems[value];
          print('VALUE');
          print(value);

          switch (value) {
            case 0:
              context.go('/companies');
              break;
            case 1:
              context.go('/contacts');
              break;
            
          }

          // context.push( menuItem.link );
          widget.scaffoldKey.currentState?.closeDrawer();
        },
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, hasNotch ? 0 : 20, 16, 0),
            child: Text('Saludos', style: textStyles.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
            child: Text('Tony Stark', style: textStyles.titleSmall),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
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
            label: Text('Tareas'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.document_scanner_sharp),
            label: Text('Documentos'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 10, 16, 10),
            child: Text('Otras opciones'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomFilledButton(
                onPressed: () {
                  context.go('/login');
                },
                text: 'Cerrar sesión'),
          ),
        ]);
  }
}

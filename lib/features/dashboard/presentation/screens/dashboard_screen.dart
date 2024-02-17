import 'package:crm_app/features/shared/shared.dart';
import 'package:floating_action_bubble_custom/floating_action_bubble_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _animationController,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const _DashboardView(),
      floatingActionButton: FloatingActionBubble(
        animation: _animation,
        onPressed: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Colors.blue,
        iconData: Icons.add,
        backgroundColor: Colors.white,
        items: <Widget>[
          /*BubbleMenu(
            title: 'Nueva tarea',
            iconColor: Colors.white,
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
            icon: Icons.task,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/task');
              _animationController.reverse();
            },
          ),*/
          BubbleMenu(
            title: 'Nueva Evento',
            iconColor: Colors.white,
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
            icon: Icons.event,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/event/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Actividad',
            iconColor: Colors.white,
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
            icon: Icons.local_activity_outlined,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/activity/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Oportunidad',
            iconColor: Colors.white,
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
            icon: Icons.work,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/opportunity/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nuevo Contacto',
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.perm_contact_cal,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/contact/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Empresa',
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.account_balance_rounded,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/company/no-id');
              _animationController.reverse();
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({super.key});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, -0.2), // Mueve el emoji hacia arriba
    ).animate(_controller);

    // Iniciar la animación
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Usamos AnimatedBuilder para animar el emoji
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: _animation.value,
                  child: child,
                );
              },
              child: const Text(
                '👋',
                style: TextStyle(
                  fontSize: 100,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              '¡Bienvenido al sistema!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
  }
}

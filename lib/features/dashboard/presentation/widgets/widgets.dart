import 'package:flutter/material.dart';

class NotificationBell extends StatelessWidget {
  final int notificationCount;

  const NotificationBell({super.key, required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Icon(
          Icons.notifications_none,
          color: Colors.grey,
          size: 40.0,
        ),
        if (notificationCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minWidth: 22,
                minHeight: 22,
              ),
              child: Text(
                '$notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

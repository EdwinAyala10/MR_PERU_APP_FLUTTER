import 'package:flutter/material.dart';

class NoExistData extends StatelessWidget {
  String textCenter;
  IconData icon;
  final Future<void> Function() onRefreshCallback;
  NoExistData({super.key, required this.onRefreshCallback, required this.textCenter, required this.icon});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshCallback,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: Text(
                  textCenter,
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}

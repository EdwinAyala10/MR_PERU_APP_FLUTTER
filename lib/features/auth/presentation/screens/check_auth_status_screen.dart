import 'package:flutter/material.dart';

class CheckAuthStatusScreen extends StatelessWidget {
  const CheckAuthStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
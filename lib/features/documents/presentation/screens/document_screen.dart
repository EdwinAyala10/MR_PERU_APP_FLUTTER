

import '../../../shared/shared.dart';
import 'package:flutter/material.dart';

class DocumentScreen extends StatelessWidget {
  final String documentId;

  const DocumentScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      body: const Center(
        child: Text('Documento en construcción'),
      ),
    );
  }
}
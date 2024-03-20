import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class CompanyDetailScreen extends StatelessWidget {
  final String companyId;

  const CompanyDetailScreen({Key? key, required this.companyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _CompanyDetailView();
  }
}

class _CompanyDetailView extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final double _appBarExpandedHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: _appBarExpandedHeight,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double collapsedHeight = AppBar().preferredSize.height;
                final double minVisibleHeight = _appBarExpandedHeight - collapsedHeight;
                final double scaleFactor = (constraints.maxHeight - minVisibleHeight) / (constraints.maxHeight - collapsedHeight);
                final double scale = (scaleFactor * (1 - 0.8)) + 0.8;

                // Calcula el tamaño de la fuente, asegurándose de que nunca sea menor que 12.0
                final double fontSize = 24.0 * scale;
                final double clampedFontSize = fontSize.clamp(12.0, double.infinity);

                return FlexibleSpaceBar(
                  title: Text(
                    'Nombre de la empresa',
                    style: TextStyle(fontSize: clampedFontSize),
                  ),
                  centerTitle: true,
                );
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Acción para editar
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Acción para eliminar
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Detalles de la empresa aquí',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    const SizedBox(height: 20.0),
                    for (int i = 0; i < 20; i++)
                      Text(
                        'Detalle $i: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse scelerisque urna eget mi commodo tincidunt.',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

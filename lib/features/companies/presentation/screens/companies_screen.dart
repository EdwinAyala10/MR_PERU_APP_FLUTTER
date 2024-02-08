import 'dart:math';

import 'package:crm_app/features/companies/presentation/widgets/company_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Empresas'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _CompaniesView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nueva empresa'),
        icon: const Icon(Icons.add),
        onPressed: () {
          context.push('/company');
        },
      ),
    );
  }
}

class _CompaniesView extends ConsumerStatefulWidget {
  const _CompaniesView();

  @override
  _CompaniesViewState createState() => _CompaniesViewState();
}

class Company {
  final String name;
  final String location;
  final double annualRevenue;
  final bool active;

  Company(this.name, this.location, this.annualRevenue, this.active);
}

class _CompaniesViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ((scrollController.position.pixels + 400) >=
          scrollController.position.maxScrollExtent) {
        //ref.read(productsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Company> companies = List.generate(
      50,
      (index) => Company(
          'Empresa $index',
          'Ubicación $index',
          Random().nextDouble() * 1000000, // Random revenue
          Random()
              .nextBool()), // Generate randomly if the company is active or inactive
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: companies.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (context, index) {
          final company = companies[index];
          return ListTile(
            title: Text(company.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ubicación: ${company.location}'),
                Text(
                    'Venta Anual: \$${company.annualRevenue.toStringAsFixed(2)}'),
              ],
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: company.active ? Colors.green : Colors.red,
              ),
            ),
            onTap: () {
              context.go('/company');
            },
          );
        },
      ),
    );
  }
}

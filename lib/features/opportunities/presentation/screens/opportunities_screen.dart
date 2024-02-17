import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Oportunidades'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _OpportunitiesView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo Oportunidad'),
        icon: const Icon(Icons.add),
        onPressed: () {
          context.push('/opportunity/no-id');
        },
      ),
    );
  }
}

class _OpportunitiesView extends ConsumerStatefulWidget {
  const _OpportunitiesView();

  @override
  _OpportunitiesViewState createState() => _OpportunitiesViewState();
}

class Opportunity {
  final String name;
  final String nameCompany;
  final String comment;
  final String namePosition;
  final String price;

  Opportunity(this.name, this.nameCompany, this.comment, this.namePosition, this.price);
}

class _OpportunitiesViewState extends ConsumerState {
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
    final List<Opportunity> contacts = List.generate(
      50,
      (index) => Opportunity(
          'Oportunidad $index',
          'Estado: Oferta enviada $index',
          'Empresa xxx',
          '20 %',
          '1500 \$' // Random revenue
          ), // Generate randomly if the company is active or inactive
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: contacts.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.nameCompany),
                Text(contact.comment),
              ],
            ),
            trailing:  Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(contact.namePosition, textAlign: TextAlign.right, style: const TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent
                  )),
                Text(contact.price, style: const TextStyle(
                    fontSize: 16,
                  )),
              ],
            ),
            leading: const Icon(
              Icons.work_rounded
            ),
            onTap: () {
              context.push('/opportunity/no-id');
            },
          );
        },
      ),
    );
  }
}

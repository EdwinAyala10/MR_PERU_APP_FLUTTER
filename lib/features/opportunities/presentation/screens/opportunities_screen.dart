import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/item_opportunity.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        ],
      ),
      body: const _OpportunitiesView(),
      floatingActionButton: FloatingActionButtonCustom(
        iconData: Icons.add,
        callOnPressed: () {
        context.push('/opportunity/new');
      }),
    );
  }
}

class _OpportunitiesView extends ConsumerStatefulWidget {
  const _OpportunitiesView();

  @override
  _OpportunitiesViewState createState() => _OpportunitiesViewState();
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
    final opportunitiesState = ref.watch(opportunitiesProvider);

    return opportunitiesState.opportunities.length > 0
        ? _ListOpportunities(opportunities: opportunitiesState.opportunities)
        : const _NoExistData();
  }
}

class _ListOpportunities extends StatelessWidget {
  final List<Opportunity> opportunities;

  const _ListOpportunities({super.key, required this.opportunities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: opportunities.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final opportunity = opportunities[index];
          return ItemOpportunity(
              opportunity: opportunity, callbackOnTap: () {
                context.push('/opportunity/${opportunity.id}');
              });
        },
      ),
    );
  }
}



class _NoExistData extends StatelessWidget {
  const _NoExistData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.business,
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
          child: const Text(
            'No hay oportunidades registradas',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}

import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchOpportunitiesCallback = Future<List<Opportunity>> Function(String ruc, String query);

class SearchOpportunityDelegate extends SearchDelegate<Opportunity?> {
  final SearchOpportunitiesCallback searchOpportunities;
  List<Opportunity> initialOpportunities;
  String ruc;

  late StreamController<List<Opportunity>> debouncedOpportunities;
  late StreamController<bool> isLoadingStream;

  Timer? _debounceTimer;

  SearchOpportunityDelegate({
    required this.searchOpportunities,
    required this.ruc,
    required this.initialOpportunities,
  }) : super(
          searchFieldLabel: 'Buscar Oportunidades',
          searchFieldStyle: const TextStyle(color: Colors.black45, fontSize: 16),
        ) {
    _initializeStreams();
  }

  void _initializeStreams() {
    debouncedOpportunities = StreamController.broadcast();
    isLoadingStream = StreamController.broadcast();
  }

  void clearStreams() {
    debouncedOpportunities.close();
    isLoadingStream.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final opportunities = await searchOpportunities(ruc, query);
      initialOpportunities = opportunities;
      debouncedOpportunities.add(opportunities);
      isLoadingStream.add(false);
    });
  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialOpportunities,
      stream: debouncedOpportunities.stream,
      builder: (context, snapshot) {
        final opportunities = snapshot.data ?? [];

        if (opportunities.isEmpty) {
          return Center(
            child: Text(
              'No existen registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: opportunities.length,
          itemBuilder: (context, index) => _OpportunityItem(
            opportunity: opportunities[index],
            onOpportunitySelected: (context, opportunity) {
              clearStreams();
              close(context, opportunity);
            },
          ),
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              spins: 10,
              infinite: true,
              child: IconButton(
                onPressed: () => query = '',
                icon: const Icon(Icons.refresh_rounded),
              ),
            );
          }

          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
              onPressed: () => query = '',
              icon: const Icon(Icons.clear),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return buildResultsAndSuggestions();
  }

  @override
  void close(BuildContext context, Opportunity? result) {
    query = '';
    clearStreams();
    super.close(context, result);
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    clearStreams();
    _initializeStreams();
    _onQueryChanged(query);
  }
}

class _OpportunityItem extends StatelessWidget {
  final Opportunity opportunity;
  final Function onOpportunitySelected;

  const _OpportunityItem({required this.opportunity, required this.onOpportunitySelected});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onOpportunitySelected(context, opportunity);
      },
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: size.width * 0.17,
                child: const Icon(Icons.adf_scanner_rounded),
              ),
              const SizedBox(width: 10),
              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.oprtNombre,
                      style: textStyles.titleMedium,
                    ),
                    Text(opportunity.oprtRuc ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

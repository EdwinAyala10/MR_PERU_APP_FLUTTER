import 'dart:async';

import 'package:crm_app/config/config.dart';
import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

typedef SearchOpportunitiesCallback = Future<List<Opportunity>> Function(String ruc, String query);
typedef ResetSearchQueryCallback = void Function();

class SearchOpportunityDelegate extends SearchDelegate<Opportunity?> {
  final SearchOpportunitiesCallback searchOpportunities;
  final ResetSearchQueryCallback resetSearchQuery;
  List<Opportunity> initialOpportunities;
  String ruc;

  late StreamController<List<Opportunity>> debouncedOpportunities;
  late StreamController<bool> isLoadingStream;

  Timer? _debounceTimer;

  SearchOpportunityDelegate({
    required this.searchOpportunities,
    required this.ruc,
    required this.resetSearchQuery,
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

  /*Widget buildResultsAndSuggestions() {
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
  }*/

  Widget buildResultsAndSuggestions() {
    return FutureBuilder<List<Opportunity>>(
      future: searchOpportunities(ruc, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar los datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No existen registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else {
          final opportunities = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemCount: opportunities.length,
            itemBuilder: (context, index) => _OpportunityItem(
              opportunity: opportunities[index],
              onOpportunitySelected: (context, oportunity) {
                clearStreams();
                close(context, oportunity);
              },
            ),
          );
        }
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
        resetSearchQuery();
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
    resetSearchQuery();
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
    final createdAt = opportunity.oprtFechaRegistro != null
        ? DateFormat('dd/MM/yyyy').format(opportunity.oprtFechaRegistro!)
        : '';
    final quoteAmount = [opportunity.oprtNombreValor, opportunity.oprtValor]
        .where((value) => (value ?? '').isNotEmpty)
        .join(' ');
    final local = [opportunity.oprtLocalNombre, opportunity.localDistrito]
        .where((value) => (value ?? '').isNotEmpty)
        .join(' - ');
    final probability = (opportunity.oprtProbabilidad ?? '').isNotEmpty
        ? '${opportunity.oprtProbabilidad}%'
        : '';
    final responsible = (opportunity.nombreUsuarioResponsable ?? '').trim();

    return GestureDetector(
      onTap: () {
        onOpportunitySelected(context, opportunity);
      },
      child: FadeIn(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          leading: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_rounded,
                color: secondaryColor,
                size: 30,
              ),
            ],
          ),
          title: Text(
            local.isNotEmpty
                ? '${opportunity.razon ?? ''} - $local'
                : (opportunity.razon ?? ''),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((opportunity.oprtNombreContacto ?? '').isNotEmpty)
                Text(
                  opportunity.oprtNombreContacto ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                ),
              Text(
                opportunity.oprtNombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              if (createdAt.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        createdAt,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (probability.isNotEmpty)
                Text(
                  probability,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600),
                ),
              if (quoteAmount.isNotEmpty)
                Text(
                  quoteAmount,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600),
                ),
              if (responsible.isNotEmpty)
                Text(
                  responsible,
                  style: const TextStyle(
                      color: Colors.blue,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w800,
                      fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

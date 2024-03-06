import 'dart:async';

import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';


typedef SearchOpportunitiesCallback = Future<List<Opportunity>> Function( String query );

class SearchOpportunityDelegate extends SearchDelegate<Opportunity?>{


  final SearchOpportunitiesCallback searchOpportunities;
  List<Opportunity> initialOpportunities;
  
  StreamController<List<Opportunity>> debouncedOpportunities = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  SearchOpportunityDelegate({
    required this.searchOpportunities,
    required this.initialOpportunities,
  }):super(
    searchFieldLabel: 'Buscar Oportunidades',
    // textInputAction: TextInputAction.done
  );

  void clearStreams() {
    debouncedOpportunities.close();
  }

  void _onQueryChanged( String query ) {
    isLoadingStream.add(true);

    print('A2AAAAAAAAAAA');

    if ( _debounceTimer?.isActive ?? false ) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration( milliseconds: 500 ), () async {
      // if ( query.isEmpty ) {
      //   debouncedCompanies.add([]);
      //   return;
      // }
      print('BBBB');

      final opportunities = await searchOpportunities( query );

      print('LLEGO  AQUI');

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

        return ListView.builder(
          itemCount: opportunities.length,
          itemBuilder: (context, index) => _OpportunityItem(
            opportunity: opportunities[index],
            onOpportunitySelected: (context, movie) {
              clearStreams();
              close(context, movie);
            },
          ),
        );
      },
    );
  }


  // @override
  // String get searchFieldLabel => 'Buscar empresa';

  @override
  List<Widget>? buildActions(BuildContext context) {

    return [

      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
            if ( snapshot.data ?? false ) {
              return SpinPerfect(
                  duration: const Duration(seconds: 20),
                  spins: 10,
                  infinite: true,
                  child: IconButton(
                    onPressed: () => query = '', 
                    icon: const Icon( Icons.refresh_rounded )
                  ),
                );
            }

             return FadeIn(
                animate: query.isNotEmpty,
                child: IconButton(
                  onPressed: () => query = '', 
                  icon: const Icon( Icons.clear )
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
        icon: const Icon( Icons.arrow_back_ios_new_rounded)
      );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    print('QUE PASO');

    _onQueryChanged(query);
    return buildResultsAndSuggestions();

  }

}

class _OpportunityItem extends StatelessWidget {

  final Opportunity opportunity;
  final Function onOpportunitySelected;

  const _OpportunityItem({
    required this.opportunity,
    required this.onOpportunitySelected
  });

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
          
              // Image
              SizedBox(
                width: size.width * 0.2,
                child: const Icon(
                  Icons.blinds_outlined
                ),
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
                    Text( opportunity.oprtRuc ?? ''),
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
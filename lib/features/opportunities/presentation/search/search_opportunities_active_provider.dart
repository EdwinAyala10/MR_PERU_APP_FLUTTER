import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryOpportunitiesProvider = StateProvider<String>((ref) => '');

final searchedOpportunitiesProvider = StateNotifierProvider<SearchedOpportunitiesNotifier, List<Opportunity>>((ref) {

  final opportunityRepository = ref.read( opportunitiesRepositoryProvider );

  return SearchedOpportunitiesNotifier(
    searchOpportunities: opportunityRepository.searchOpportunities, 
    ref: ref
  );
});


typedef SearchOpportunitiesCallback = Future<List<Opportunity>> Function(String query);

class SearchedOpportunitiesNotifier extends StateNotifier<List<Opportunity>> {

  final SearchOpportunitiesCallback searchOpportunities;
  final Ref ref;

  SearchedOpportunitiesNotifier({
    required this.searchOpportunities,
    required this.ref,
  }): super([]);


  Future<List<Opportunity>> searchOpportunitiesByQuery( String query ) async{
    
    print('SEARCH OPO');

    final List<Opportunity> opportunities = await searchOpportunities(query);
    ref.read(searchQueryOpportunitiesProvider.notifier).update((state) => query);

    state = opportunities;
    return opportunities;
  }

}







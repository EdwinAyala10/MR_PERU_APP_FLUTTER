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


typedef SearchOpportunitiesCallback = Future<List<Opportunity>> Function(String ruc, String query);

class SearchedOpportunitiesNotifier extends StateNotifier<List<Opportunity>> {

  final SearchOpportunitiesCallback searchOpportunities;
  final Ref ref;

  SearchedOpportunitiesNotifier({
    required this.searchOpportunities,
    required this.ref,
  }): super([]);


  Future<List<Opportunity>> searchOpportunitiesByQuery(String ruc, String query ) async{
    
    final List<Opportunity> opportunities = await searchOpportunities(ruc, query);
    ref.read(searchQueryOpportunitiesProvider.notifier).update((state) => query);

    state = opportunities;
    return opportunities;
  }

}







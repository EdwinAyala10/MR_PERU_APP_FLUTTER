import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedCompaniesProvider = StateNotifierProvider<SearchedCompaniesNotifier, List<Company>>((ref) {

  final companyRepository = ref.read( companiesRepositoryProvider );

  return SearchedCompaniesNotifier(
    searchCompaniesActive: companyRepository.searchCompaniesActive, 
    ref: ref
  );
});


typedef SearchCompaniesCallback = Future<List<Company>> Function(String dni, String query);

class SearchedCompaniesNotifier extends StateNotifier<List<Company>> {

  final SearchCompaniesCallback searchCompaniesActive;
  final Ref ref;

  SearchedCompaniesNotifier({
    required this.searchCompaniesActive,
    required this.ref,
  }): super([]);


  Future<List<Company>> searchCompaniesByQuery( String query ) async{
    
    final List<Company> companies = await searchCompaniesActive('10722843', query);
    ref.read(searchQueryProvider.notifier).update((state) => query);

    state = companies;
    return companies;
  }

}







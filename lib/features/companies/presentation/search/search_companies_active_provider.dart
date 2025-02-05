import '../../domain/domain.dart';
import '../providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryCompaniesProvider = StateProvider<String>((ref) => '');

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


  Future<List<Company>> searchCompaniesByQuery(String dni, String query) async{
    
    final List<Company> companies = await searchCompaniesActive(dni, query);
    ref.read(searchQueryCompaniesProvider.notifier).update((state) => query);

    state = companies;
    return companies;
  }

}







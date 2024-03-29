import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryCompanyLocalesProvider = StateProvider<String>((ref) => '');

final searchedCompanyLocalesProvider = StateNotifierProvider<SearchedCompanyLocalesNotifier, List<CompanyLocal>>((ref) {

  final companyLocalRepository = ref.read( companiesRepositoryProvider );

  return SearchedCompanyLocalesNotifier(
    searchCompanyLocalesActive: companyLocalRepository.searchCompanyLocalesActive, 
    ref: ref
  );
});


typedef SearchCompanyLocalesCallback = Future<List<CompanyLocal>> Function(String ruc, String query);

class SearchedCompanyLocalesNotifier extends StateNotifier<List<CompanyLocal>> {

  final SearchCompanyLocalesCallback searchCompanyLocalesActive;
  final Ref ref;

  SearchedCompanyLocalesNotifier({
    required this.searchCompanyLocalesActive,
    required this.ref,
  }): super([]);


  Future<List<CompanyLocal>> searchCompanyLocalesByQuery(String ruc, String query ) async{
    
    print('SEARCH COMP LOCAL');

    final List<CompanyLocal> companyLocales = await searchCompanyLocalesActive(ruc, query);
    ref.read(searchQueryCompanyLocalesProvider.notifier).update((state) => query);

    state = companyLocales;
    return companyLocales;
  }

}







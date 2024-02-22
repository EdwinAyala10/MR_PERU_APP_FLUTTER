import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

import 'companies_repository_provider.dart';


final companiesProvider = StateNotifierProvider<CompaniesNotifier, CompaniesState>((ref) {

  final companiesRepository = ref.watch( companiesRepositoryProvider );
  return CompaniesNotifier(
    companiesRepository: companiesRepository
  );
  
});





class CompaniesNotifier extends StateNotifier<CompaniesState> {
  
  final CompaniesRepository companiesRepository;

  CompaniesNotifier({
    required this.companiesRepository
  }): super( CompaniesState() ) {
    loadNextPage();
  }

  Future<bool> createOrUpdateCompany( Map<String,dynamic> companyLike ) async {

    try {
      final company = await companiesRepository.createUpdateCompany(companyLike);
      final isCompanyInList = state.companies.any((element) => element.ruc == company.ruc );

      if ( !isCompanyInList ) {
        state = state.copyWith(
          companies: [...state.companies, company]
        );
        return true;
      }

      state = state.copyWith(
        companies: state.companies.map(
          (element) => ( element.ruc == company.ruc ) ? company : element,
        ).toList()
      );
      return true;

    } catch (e) {
      return false;
    }


  }

  Future loadNextPage() async {

    if ( state.isLoading || state.isLastPage ) return;

    state = state.copyWith( isLoading: true );

    final companies = await companiesRepository
      .getCompanies();

    if ( companies.isEmpty ) {
      state = state.copyWith(
        isLoading: false,
        isLastPage: true
      );
      return;
    }

    state = state.copyWith(
      isLastPage: false,
      isLoading: false,
      offset: state.offset + 10,
      companies: [...state.companies, ...companies ]
    );

  }
}


class CompaniesState {

  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Company> companies;

  CompaniesState({
    this.isLastPage = false, 
    this.limit = 10, 
    this.offset = 0, 
    this.isLoading = false, 
    this.companies = const[]
  });

  CompaniesState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Company>? companies,
  }) => CompaniesState(
    isLastPage: isLastPage ?? this.isLastPage,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    isLoading: isLoading ?? this.isLoading,
    companies: companies ?? this.companies,
  );

}

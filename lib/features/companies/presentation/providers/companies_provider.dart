import 'package:crm_app/features/companies/domain/entities/create_update_company_local_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

import 'companies_repository_provider.dart';

final companiesProvider =
    StateNotifierProvider<CompaniesNotifier, CompaniesState>((ref) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  return CompaniesNotifier(companiesRepository: companiesRepository);
});

class CompaniesNotifier extends StateNotifier<CompaniesState> {
  final CompaniesRepository companiesRepository;

  CompaniesNotifier({required this.companiesRepository})
      : super(CompaniesState()) {
    loadNextPage();
  }

  Future<CreateUpdateCompanyResponse> createOrUpdateCompany(
      Map<dynamic, dynamic> companyLike) async {
    try {
      final companyResponse =
          await companiesRepository.createUpdateCompany(companyLike);

      final message = companyResponse.message;

      if (companyResponse.status) {

        final company = companyResponse.company as Company;
        final isCompanyInList =
            state.companies.any((element) => element.ruc == company.ruc);

        if (!isCompanyInList) {
          state = state.copyWith(companies: [company, ...state.companies]);
          return CreateUpdateCompanyResponse(response: true, message: message);
        }

        state = state.copyWith(
            companies: state.companies
                .map(
                  (element) => (element.ruc == company.ruc) ? company : element,
                )
                .toList());

        return CreateUpdateCompanyResponse(response: true, message: message);
      }

      return CreateUpdateCompanyResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateCompanyResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future<CreateUpdateCompanyCheckInResponse> createOrUpdateCompanyCheckIn(
      Map<dynamic, dynamic> companyCheckInLike) async {
    try {
      final companyCheckInResponse =
          await companiesRepository.createCompanyCheckIn(companyCheckInLike);

      final message = companyCheckInResponse.message;

      if (companyCheckInResponse.status) {

        //final companyCheckIn = companyCheckInResponse.companyCheckIn as CompanyCheckIn;
        /*final companyCheckIn = companyCheckInResponse.company as Company;
        final isCompanyInList =
            state.companies.any((element) => element.ruc == company.ruc);

        if (!isCompanyInList) {
          state = state.copyWith(companies: [...state.companies, company]);
          return CreateUpdateCompanyResponse(response: true, message: message);
        }

        state = state.copyWith(
            companies: state.companies
                .map(
                  (element) => (element.ruc == company.ruc) ? company : element,
                )
                .toList());*/

        return CreateUpdateCompanyCheckInResponse(response: true, message: message);
      }

      return CreateUpdateCompanyCheckInResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateCompanyCheckInResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }

  /*Future<CreateUpdateCompanyLocalResponse> createOrUpdateCompanyLocal(
      Map<dynamic, dynamic> companyLocalLike) async {
    try {
      final companyLocalResponse =
          await companiesRepository.createUpdateCompanyLocal(companyLocalLike);

      final message = companyLocalResponse.message;

      if (companyLocalResponse.status) {

        //final companyCheckIn = companyCheckInResponse.companyCheckIn as CompanyCheckIn;
        /*final companyCheckIn = companyCheckInResponse.company as Company;
        final isCompanyInList =
            state.companies.any((element) => element.ruc == company.ruc);

        if (!isCompanyInList) {
          state = state.copyWith(companies: [...state.companies, company]);
          return CreateUpdateCompanyResponse(response: true, message: message);
        }

        state = state.copyWith(
            companies: state.companies
                .map(
                  (element) => (element.ruc == company.ruc) ? company : element,
                )
                .toList());*/

        return CreateUpdateCompanyLocalResponse(response: true, message: message);
      }

      return CreateUpdateCompanyLocalResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateCompanyLocalResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }*/


  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final companies = await companiesRepository.getCompanies();

    if (companies.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        companies: [...state.companies, ...companies]);
  }
}

class CompaniesState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Company> companies;

  CompaniesState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.companies = const []});

  CompaniesState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Company>? companies,
  }) =>
      CompaniesState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        companies: companies ?? this.companies,
      );
}

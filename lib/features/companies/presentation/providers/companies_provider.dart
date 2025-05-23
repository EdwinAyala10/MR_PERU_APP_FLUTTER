import 'dart:async';
import 'dart:developer';

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/auth/domain/entities/user.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

import 'companies_repository_provider.dart';

final companiesProvider =
    StateNotifierProvider<CompaniesNotifier, CompaniesState>((ref) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  final user = ref.read(authProvider);
  return CompaniesNotifier(
    companiesRepository: companiesRepository,
    user: user.user,
  );
});


/// [Para agilizar el desarroollo de los clientes incorpore directamente DIO en el providoer state, esto de momento en cuanto haya la oportunidad se necesatara realizar un refactor]
class CompaniesNotifier extends StateNotifier<CompaniesState> {
  final CompaniesRepository companiesRepository;
  Dio client = Dio();
  final User? user;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }


  CompaniesNotifier({
    required this.companiesRepository,
    this.user,
  }) : super(CompaniesState()) {
    client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer ${user?.token}'},
        baseUrl: Environment.apiUrl,
      ),
    );
    loadNextPage(isRefresh: true);
  }

  Future<void> validateCheckIn({
    required String ruc,
    String? idEvent,
  }) async {
    try {
      final form = {
        "RUC": ruc,
        "ID_USUARIO_RESPONSABLE": user?.code ?? '',
      };
      const endPoint = '/cliente-check/validar-checkin';
      final request = await client.post(
        endPoint,
        data: form,
      );
      log(request.toString());
      if (request.data['status'] == true) {
        state = state.copyWith(
          isValidateCheckIn: true,
          validationCheckinMessage: request.data['message'] ?? '',
        );
        return;
      }
      state = state.copyWith(
        isValidateCheckIn: false,
        validationCheckinMessage: request.data['message'] ?? '',
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<CreateUpdateCompanyResponse> createOrUpdateCompany(
      Map<dynamic, dynamic> companyLike) async {
    try {
      final companyResponse =
          await companiesRepository.createUpdateCompany(companyLike);

      final message = companyResponse.message;

      if (companyResponse.status) {
        /*final company = companyResponse.company as Company;
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
                .toList());*/

        return CreateUpdateCompanyResponse(response: true, message: message);
      }

      return CreateUpdateCompanyResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateCompanyResponse(
          response: false, message: 'Error, revisar con su administrador.');
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

        return CreateUpdateCompanyCheckInResponse(
            response: true, message: message);
      }

      return CreateUpdateCompanyCheckInResponse(
          response: false, message: message);
    } catch (e) {
      return CreateUpdateCompanyCheckInResponse(
          response: false, message: 'Error, revisar con su administrador.');
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

  void loadAddressCompanyByRuc(String ruc) {
    Company foundCompany =
        state.companies.firstWhere((company) => company.ruc == ruc);

    foundCompany.localCantidad = '2';

    state = state.copyWith(
        companies: state.companies
            .map(
              (element) => (element.ruc == ruc) ? foundCompany : element,
            )
            .toList());
  }

  void onChangeIsActiveSearch() {
    state = state.copyWith(
      isActiveSearch: true,
    );
  }

  void onChangeTextSearch(String text) {
    state = state.copyWith(textSearch: text);
    loadNextPage(isRefresh: true);
  }

  void onChangeNotIsActiveSearch() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
    loadNextPage(isRefresh: true);
    //}
  }

  void onChangeNotIsActiveSearchSinRefresh() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
    //loadNextPage(isRefresh: true);
    //}
  }

  Future loadNextPage({bool isRefresh = false}) async {
    final search = state.textSearch;

    // Cancelar el debounce anterior si está activo
    //if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (isRefresh) {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);
    } else {
      if (state.isReload || state.isLastPage) return;
      state = state.copyWith(isReload: true);
    }

    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    } else {
      sOffset = state.offset + 10;
    }

   // _debounce = Timer(const Duration(milliseconds: 1000), () async {
      // Llamada al repositorio de búsqueda
      //final companies = await getCompanies(search: search, limit: limit, offset: offset);
      //state = companies; // Actualizar el estado con los resultados

      final companies = await companiesRepository.getCompanies(
        search: search, limit: sLimit, offset: sOffset);

      if (companies.isEmpty) {
        if (isRefresh) {
          state = state.copyWith(isLoading: false, isLastPage: true);
        } else {
          state = state.copyWith(isReload: false, isLastPage: true);
        }
        return;
      } else {
        int newOffset;
        List<Company> newCompanies;

        if (isRefresh) {
          newOffset = 0;
          newCompanies = companies;
        } else {
          newOffset = sOffset;
          newCompanies = [...state.companies, ...companies];
        }

        if (isRefresh) {
          state = state.copyWith(
              isLastPage: false,
              isLoading: false,
              offset: newOffset,
              companies: newCompanies);
        } else {
          state = state.copyWith(
              isLastPage: false,
              isReload: false,
              offset: newOffset,
              companies: newCompanies);
        }
      }

   
    //});

   

  }

  /*Future loadNextPage(String search) async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final companies = await companiesRepository.getCompanies(
      search: search,
      limit: state.limit,
      offset: state.offset
    );

    if (companies.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        //offset: state.offset + 10,
        companies: companies
    );

    /*state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        companies: [...state.companies, ...companies]
        //companies: companies
    );*/
  }*/
}

class CompaniesState {
  final bool isLastPage;
  final bool isReload;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Company> companies;
  final bool isActiveSearch;
  final String textSearch;
  final bool isValidateCheckIn;
  final String validationCheckinMessage;

  CompaniesState(
      {this.isLastPage = false,
      this.isReload = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isActiveSearch = false,
      this.isValidateCheckIn = false,
      this.validationCheckinMessage = '',
      this.textSearch = '',
      this.companies = const []});

  CompaniesState copyWith({
    bool? isLastPage,
    bool? isReload,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isActiveSearch,
    String? textSearch,
    bool? isValidateCheckIn,
    String? validationCheckinMessage,
    List<Company>? companies,
  }) =>
      CompaniesState(
          isLastPage: isLastPage ?? this.isLastPage,
          isReload: isReload ?? this.isReload,
          limit: limit ?? this.limit,
          offset: offset ?? this.offset,
          isLoading: isLoading ?? this.isLoading,
          companies: companies ?? this.companies,
          isActiveSearch: isActiveSearch ?? this.isActiveSearch,
          textSearch: textSearch ?? this.textSearch,
          validationCheckinMessage:
              validationCheckinMessage ?? this.validationCheckinMessage,
          isValidateCheckIn: isValidateCheckIn ?? this.isValidateCheckIn);
}

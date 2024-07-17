import 'package:crm_app/features/route-planner/presentation/providers/route_planner_repository_provider.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';


final routePlannerProvider =
    StateNotifierProvider<RoutePlannerNotifier, RoutePlannerState>((ref) {
  final routePlannerRepository = ref.watch(routePlannerRepositoryProvider);
  return RoutePlannerNotifier(routePlannerRepository: routePlannerRepository);
});


class RoutePlannerNotifier extends StateNotifier<RoutePlannerState> {
  final RoutePlannerRepository routePlannerRepository;

  RoutePlannerNotifier({required this.routePlannerRepository})
      : super(RoutePlannerState()) {
    loadNextPage(isRefresh: true);
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

  void onSelectedFilter(FilterOption opt) {
    bool found = false;

    // Usando una lista mutable para actualizar los filtros.
    List<FilterOption> updatedFilters = List.from(state.filters);

    for (int i = 0; i < updatedFilters.length; i++) {
      if (updatedFilters[i].type == opt.type) {
        updatedFilters[i] = opt;
        found = true;
        break;
      }
    }

    if (!found) {
      updatedFilters.add(opt);
    }

    // Actualizar el estado con los filtros modificados.
    state = state.copyWith(filters: updatedFilters);
  }

  void setLocalesOrder(List<CompanyLocalRoutePlanner> localesOrder) {
    state = state.copyWith(
      locales: localesOrder,
    );
  }

  void onDeleteAllFilter() {
    state = state.copyWith(filtersSuccess: [], filters: []);
    loadNextPage(isRefresh: true);
  }

  void onDeleteFilter(int index) {
    var filterSuccessNew = [...state.filtersSuccess];
    filterSuccessNew.removeAt(index);
    state = state.copyWith(filters: filterSuccessNew, filtersSuccess: filterSuccessNew);
    loadNextPage(isRefresh: true);
  }

  Future<List<DropdownOption>> loadFilterActivity() async {
    //state = state.copyWith(isLoading: true);

    List<FilterActivity> filters =
        await routePlannerRepository.getFilterActivities();

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(
          DropdownOption(id: filter.valor, name: filter.descripcion));
    }

    return options;
  }

  Future<List<DropdownOption>> loadFilterResponsable() async {
    //state = state.copyWith(isLoading: true);

    List<FilterResponsable> filters =
        await routePlannerRepository.getFilterResponsable(search: '');

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(DropdownOption(id: filter.userreportCodigo, name: filter.userreportName));
    }

    return options;
  }

  void onCheckItem(CompanyLocalRoutePlanner company) {
    print('onCheckItem localCodigo: ${company.localCodigo}');
    print('onCheckItem ruc: ${company.ruc}');
    bool exists = state.selectedItems.any((item) => item.ruc == company.ruc && item.localCodigo == company.localCodigo);
    print(exists);
    print('onCheckItem total: ${state.selectedItems.length}');
    if (!exists) {
      state = state.copyWith(
        selectedItems: [...state.selectedItems, company]
      );
    } else {
      List<CompanyLocalRoutePlanner> newItems = [...state.selectedItems];
      newItems.remove(company);
      state = state.copyWith(
        selectedItems: newItems
      );
    } 
  }

  Future<List<DropdownOption>> loadFilterCodigoPostal() async {
    //state = state.copyWith(isLoading: true);

    List<FilterCodigoPostal> filters =
        await routePlannerRepository.getFilterCodigoPostal(search: '');

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(DropdownOption(id: filter.localCodigoPostal, name: filter.localCodigoPostal));
    }

    return options;
  }

  Future<List<DropdownOption>> loadFilterDistrito() async {
    //state = state.copyWith(isLoading: true);

    List<FilterDistrito> filters =
        await routePlannerRepository.getFilterDistrito(search: '');

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
      options.add(DropdownOption(id: filter.distrito, name: filter.distrito));
    }

    return options;
  }

  void sendLoadFilter() {
    state = state.copyWith(
      filtersSuccess: state.filters
    );
    loadNextPage(isRefresh: true);
  }

  Future<List<DropdownOption>> loadFilterRuc() async {
    //state = state.copyWith(isLoading: true);

    List<FilterRucRazonSocial> filters =
        await routePlannerRepository.getFilterRucRazonSocial(search: '');

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(
          DropdownOption(id: filter.ruc, name: filter.ruc,  subTitle: filter.razon, secundary: filter.tipoCliente));
    }

    return options;
  }

  Future<List<DropdownOption>> loadFiltecRazonComercial() async {
    //state = state.copyWith(isLoading: true);

    List<FilterRucRazonSocial> filters =
        await routePlannerRepository.getFilterRucRazonSocial(search: '');

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(
          DropdownOption(id: filter.razonComercial, name: filter.razonComercial, subTitle: filter.razon, secundary: filter.tipoCliente));
    }

    return options;
  }


  Future loadNextPage({bool isRefresh = false}) async {
    final search = state.textSearch;

    //if (state.isLoading || state.isLastPage) return;
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    }

    final locales = await routePlannerRepository.getCompanyLocals(
      search: search, 
      limit: sLimit, 
      offset: sOffset,
      filters: state.filtersSuccess
    );

    if (locales.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true, locales: []);
      state = state.copyWith(isLoading: false, locales: []);
      //return;
    } else {
      int newOffset;
      List<CompanyLocalRoutePlanner> newLocales;

      if (isRefresh) {
        newOffset = 0;
        newLocales = locales;
      } else {
        newOffset = state.offset + 10;
        newLocales = [...state.locales, ...locales];
      }
      
      state = state.copyWith(
          //isLastPage: false,
          isLoading: false,
          offset: newOffset,
          locales: newLocales);
    }
   
  }
}

class RoutePlannerState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<CompanyLocalRoutePlanner> locales;
  final bool isActiveSearch;
  final String textSearch;
  final List<FilterOption> filters;
  final List<FilterOption> filtersSuccess;
  final List<CompanyLocalRoutePlanner> selectedItems;

  RoutePlannerState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.filters = const [],
      this.filtersSuccess = const [],
      this.locales = const [],
      this.selectedItems = const []});

  RoutePlannerState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isActiveSearch,
    String? textSearch,
    List<CompanyLocalRoutePlanner>? locales,
    List<FilterOption>? filters,
    List<FilterOption>? filtersSuccess,
    List<CompanyLocalRoutePlanner>? selectedItems,
  }) =>
      RoutePlannerState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        locales: locales ?? this.locales,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
        textSearch: textSearch ?? this.textSearch,
        filters: filters ?? this.filters,
        filtersSuccess: filtersSuccess ?? this.filtersSuccess,
        selectedItems: selectedItems ?? this.selectedItems,
      );
}

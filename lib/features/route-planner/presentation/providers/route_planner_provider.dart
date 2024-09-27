import 'package:crm_app/features/route-planner/domain/entities/coordenada.dart';
import 'package:crm_app/features/route-planner/domain/entities/create_event_planner_response.dart';
import 'package:crm_app/features/route-planner/domain/entities/validate_event_planner_response.dart';
import 'package:crm_app/features/route-planner/domain/entities/validate_horario_trabajo_response.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_repository_provider.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:flutter/material.dart';
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

  void onChangeNotIsActiveSearchSinRefresh() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
    //loadNextPage(isRefresh: true);
    //}
  }

  void onSelectedFilter(FilterOption opt, bool isMulti) {
    bool found = false;

    print('options id: ${opt.id}');
    print('options name: ${opt.name}');
    print('options title: ${opt.title}');
    print('options type: ${opt.type}');

    // Usando una lista mutable para actualizar los filtros.
    List<FilterOption> updatedFilters = List.from(state.filters);

    for (int i = 0; i < updatedFilters.length; i++) {
      if (updatedFilters[i].type == opt.type) {

        if (isMulti) {

          var stringIds = updatedFilters[i].id;

          
          List<String> lists = stringIds.split(',');

          if (!lists.contains(opt.id)) {
            lists.add(opt.id);
          } else {
            lists.remove(opt.id);
          }

          String joinList = lists.join(',');

          print(joinList);

          var optNew = FilterOption(id: joinList, type: opt.type, title: opt.title, name: joinList);
          updatedFilters[i] = optNew;
        }else {
          updatedFilters[i] = opt;
        }

        found = true;
        break;
      }
    }

    if (!found) {
      if (isMulti) {
        List<String> lists = [];

        lists.add(opt.id);

        String joinList = lists.join(',');

        var optNew = FilterOption(id: joinList, type: opt.type, title: opt.title, name: joinList);
        updatedFilters.add(optNew);

      }else {
        updatedFilters.add(opt);
      }

    }

    print(updatedFilters);

    // Actualizar el estado con los filtros modificados.
    state = state.copyWith(filters: updatedFilters);
  }

  /*onLocalesTemp() {
    print('INICIO CAN START onLocalesTemp');

    state = state.copyWith(
      localesOrderTemp: state.locales
    );
  }*/

  /*onSetLocalesTmpInLocales() {
    state = state.copyWith(
      locales: state.localesOrderTemp
    );
  }*/

  int indexOfKey(Key key) {
    return state.selectedItems.indexWhere((CompanyLocalRoutePlanner d) => d.key == key);
  }

  bool onReorder(Key item, Key newPosition, List<CompanyLocalRoutePlanner> list) {

    int draggingIndex = indexOfKey(item);
    int newPositionIndex = indexOfKey(newPosition);

    final draggedItem = state.selectedItems[draggingIndex];

    final newListSelectedItems = [...state.selectedItems];

    newListSelectedItems.removeAt(draggingIndex);
    newListSelectedItems.insert(newPositionIndex, draggedItem);
    
    state = state.copyWith(
      selectedItems: newListSelectedItems
    );
  
    return true;
  }

  Future<void> setSelectedItemsOrder(List<CompanyLocalRoutePlanner> selectedItemsOrder) async {
    state = state.copyWith(
      selectedItems: selectedItemsOrder,
    );
  }

  Future<void> initialOrderkey()  async {
    List<CompanyLocalRoutePlanner> newListItemsSelected = [];
    List<CompanyLocalRoutePlanner> oldListItemsSelected = state.selectedItems;

    for (var i = 0; i < oldListItemsSelected.length; i++) {
      CompanyLocalRoutePlanner local = oldListItemsSelected[i];
      local.key = ValueKey(i);
  
      newListItemsSelected.add(local);
    }

    state = state.copyWith(
      selectedItems: newListItemsSelected
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

  Future<Coordenada> cargarCoordena() async {

    Coordenada coors =
        await routePlannerRepository.getCoordenadas();
    return coors;
  }

   Future<List<DropdownOption>> loadFilterHorarioTrabajo() async {
    //state = state.copyWith(isLoading: true);

    List<FilterHorarioTrabajo> filters =
        await routePlannerRepository.getFilterHorarioTrabajo();

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(
          DropdownOption(id: filter.hrtrIdHorarioTrabajo!, name: filter.hrtrDescricion!));
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
      print('eliminar item');
      List<CompanyLocalRoutePlanner> newItems = [...state.selectedItems];

      newItems.removeWhere((item) => item.ruc == company.ruc && item.localCodigo == company.localCodigo);
      //newItems.remove(company);
      print('total elimnado: ${newItems.length } ');
      state = state.copyWith(
        selectedItems: newItems
      );
    } 
  }

   Future<void> loadFilterHorario() async {


    ValidateHorarioTrabajoResponse validate =
        await routePlannerRepository.getHorarioTrabajo();

    if (validate.status) {

      List<FilterOption> filtersA = [...state.filtersSuccess];

      // Verifica si ya existe un filtro con el mismo id
      bool exists = filtersA.any((filter) => filter.type == 'HRTR_ID_HORARIO_TRABAJO');
      
      print('EXIST: ${exists}' );
      if (!exists) {
 
        var nuevo = FilterOption(
          id: validate.data?.idHorarioTrabajo ?? '', 
          type: 'HRTR_ID_HORARIO_TRABAJO', 
          title: 'Horario de trabajo', 
          name: validate.data?.descripcion ?? '');
      
        List<FilterOption> filtersb = [nuevo, ...state.filtersSuccess];

          state = state.copyWith(
            filtersSuccess: filtersb,
            filters: filtersb
          );
      }
    } 

  
  }

  Future<List<DropdownOption>> loadFilterCodigoPostal(String search) async {
    //state = state.copyWith(isLoading: true);

    List<FilterCodigoPostal> filters =
        await routePlannerRepository.getFilterCodigoPostal(search: search);

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(DropdownOption(id: filter.localCodigoPostal, name: filter.localCodigoPostal));
    }

    return options;
  }

  Future<List<DropdownOption>> loadFilterDistrito(String search) async {
    //state = state.copyWith(isLoading: true);

    List<FilterDistrito> filters =
        await routePlannerRepository.getFilterDistrito(search: search);

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
      options.add(DropdownOption(id: filter.distrito, name: filter.distrito));
    }

    return options;
  }

  void updateFechasRegister(String dateIni, String datetEnd) {
    state = state.copyWith(
      dateTimeInitial: dateIni,
      dateTimeEnd: datetEnd
    );
  }

  Future<ValidateEventPlannerResponse> validatePlanner(String idHorario) async {
    //state = state.copyWith(isLoading: true);

    final event = {
      'PLRT_ID_HORARIO_TRABAJO': idHorario,
      'EVENTOS_PLANIFICADOR_RUTA': state.selectedItems != null
          ? List<dynamic>.from(
              state.selectedItems!.map((x) => x.toJson()))
          : [],
    };

    ValidateEventPlannerResponse validate =
        await routePlannerRepository.validateEventPlanner(event);

    return validate;
  }

  void sendLoadFilter() {
    state = state.copyWith(
      filtersSuccess: state.filters
    );
    loadNextPage(isRefresh: true);
  }

  Future<List<DropdownOption>> loadFilterRuc(String search) async {
    //state = state.copyWith(isLoading: true);

    List<FilterRucRazonSocial> filters =
        await routePlannerRepository.getFilterRucRazonSocial(search: search);

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(
          DropdownOption(
            id: filter.ruc, 
            name: filter.ruc,  
            subTitle: filter.razon, 
            secundary: filter.tipoCliente));
    }

    return options;
  }

  Future<List<DropdownOption>> loadFiltecRazonComercial(String search) async {
    //state = state.copyWith(isLoading: true);

    List<FilterRucRazonSocial> filters =
        await routePlannerRepository.getFilterRucRazonSocial(search: search);

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
        options.add(
          DropdownOption(id: filter.razonComercial, name: filter.razonComercial, subTitle: filter.razon, secundary: filter.tipoCliente));
    }

    return options;
  }

  Future<CreateEventPlannerResponse> createEventPlanner(
      Map<dynamic, dynamic> eventLike) async {
    try {
      final eventResponse = await routePlannerRepository.createEventPlanner(eventLike);

      final message = eventResponse.message;

      if (eventResponse.status) {
        return CreateEventPlannerResponse(response: true, message: message);
      }

      return CreateEventPlannerResponse(response: false, message: message);
    } catch (e) {
      return CreateEventPlannerResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

  void clearSelectedLocales() {
    state = state.copyWith(
      selectedItems: []
    );
  }

  Future loadNextPage({bool isRefresh = false}) async {
    final search = state.textSearch;

    if (isRefresh) {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);
    } else {
      if (state.isReload || state.isLastPage) return;  
      state = state.copyWith(isReload: true);
    }

    //if (state.isLoading || state.isLastPage) return;
    //if (state.isLoading) return;

    //state = state.copyWith(isLoading: true);

    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    } else {
      sOffset = state.offset + 10;
    }

    print('sLimit x: ${sLimit}');
    print('sOffset x: ${sOffset}');

    final locales = await routePlannerRepository.getCompanyLocals(
      search: search, 
      limit: sLimit, 
      offset: sOffset,
      filters: state.filtersSuccess
    );

    if (locales.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true, locales: []);
      if (isRefresh) {
        state = state.copyWith(isLoading: false, isLastPage: true);    
      } else {
        state = state.copyWith(isReload: false, isLastPage: true);
      }
      //state = state.copyWith(isLoading: false, locales: []);
      return;
    } else {
      int newOffset;
      List<CompanyLocalRoutePlanner> newLocales;

      if (isRefresh) {
        newOffset = 0;
        newLocales = locales;
      } else {
        //newOffset = state.offset + 10;
        newOffset = sOffset;
        newLocales = [...state.locales, ...locales];
      }

      print('Offset: ${newOffset}');

      if (isRefresh) {
        state = state.copyWith(
          isLastPage: false,
          isLoading: false,
          offset: newOffset,
          locales: newLocales);
      } else {
        state = state.copyWith(
          isLastPage: false,
          isReload: false,
          offset: newOffset,
          locales: newLocales);
      }
      
    }
   
  }
}

class RoutePlannerState {
  final bool isLastPage;
  final int limit;
  final bool isReload;
  final int offset;
  final bool isLoading;
  final List<CompanyLocalRoutePlanner> locales;
  //final List<CompanyLocalRoutePlanner> localesOrderTemp;
  final bool isActiveSearch;
  final String textSearch;
  final List<FilterOption> filters;
  final List<FilterOption> filtersSuccess;
  final List<CompanyLocalRoutePlanner> selectedItems;
  final String? dateTimeInitial;
  final String? dateTimeEnd;

  RoutePlannerState(
      {this.isLastPage = false,
      this.isReload = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.filters = const [],
      this.filtersSuccess = const [],
      this.locales = const [],
      //this.localesOrderTemp = const [],
      this.selectedItems = const [],
      this.dateTimeInitial =  '',
      this.dateTimeEnd =  '' 
      });

  RoutePlannerState copyWith({
    bool? isLastPage,
    bool? isReload,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isActiveSearch,
    String? textSearch,
    List<CompanyLocalRoutePlanner>? locales,
    //List<CompanyLocalRoutePlanner>? localesOrderTemp,
    List<FilterOption>? filters,
    List<FilterOption>? filtersSuccess,
    List<CompanyLocalRoutePlanner>? selectedItems,
    String? dateTimeInitial,
    String? dateTimeEnd
  }) =>
      RoutePlannerState(
        isLastPage: isLastPage ?? this.isLastPage,
        isReload: isReload ?? this.isReload,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        locales: locales ?? this.locales,
        //localesOrderTemp: localesOrderTemp ?? this.localesOrderTemp,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
        textSearch: textSearch ?? this.textSearch,
        filters: filters ?? this.filters,
        filtersSuccess: filtersSuccess ?? this.filtersSuccess,
        selectedItems: selectedItems ?? this.selectedItems,
        dateTimeInitial: dateTimeInitial ?? this.dateTimeInitial,
        dateTimeEnd: dateTimeEnd ?? this.dateTimeEnd,
      );
}

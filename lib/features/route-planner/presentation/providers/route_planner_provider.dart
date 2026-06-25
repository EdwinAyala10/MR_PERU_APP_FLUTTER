import 'dart:developer';
import 'dart:math' hide log;

import 'package:crm_app/features/auth/domain/entities/user.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/resource-detail/domain/repositories/resource_details_repository.dart';
import 'package:crm_app/features/resource-detail/presentation/providers/resource_details_repository_provider.dart';
import 'package:crm_app/features/route-planner/domain/entities/coordenada.dart';
import 'package:crm_app/features/route-planner/domain/entities/create_event_planner_response.dart';
import 'package:crm_app/features/route-planner/domain/entities/distance_filter.dart';
import 'package:crm_app/features/route-planner/domain/entities/validate_event_planner_response.dart';
import 'package:crm_app/features/route-planner/domain/entities/validate_horario_trabajo_response.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_repository_provider.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import '../../domain/domain.dart';

// Clase helper para distinguir entre null explícito y parámetro no proporcionado
class _Undefined {
  const _Undefined();
}

final routePlannerProvider =
    StateNotifierProvider<RoutePlannerNotifier, RoutePlannerState>((ref) {
  final routePlannerRepository = ref.watch(routePlannerRepositoryProvider);
  final resourceDetailsRepProvider =
      ref.read(resourceDetailsRepositoryProvider);
  final user = ref.read(authProvider);
  return RoutePlannerNotifier(
    routePlannerRepository: routePlannerRepository,
    resourceDetailsRepository: resourceDetailsRepProvider,
    user: user.user,
    ref: ref,
  );
});

final userResponsableProvider = StateProvider<String>((ref) => '');

/// [Para agilizar el desarroollo de los clientes incorpore directamente DIO en el providoer state, esto de momento en cuanto haya la oportunidad se necesatara realizar un refactor]
class RoutePlannerNotifier extends StateNotifier<RoutePlannerState> {
  final RoutePlannerRepository routePlannerRepository;
  final ResourceDetailsRepository resourceDetailsRepository;
  final User? user;
  final Ref ref;
  Dio client = Dio();

  RoutePlannerNotifier({
    required this.routePlannerRepository,
    required this.resourceDetailsRepository,
    required this.ref,
    this.user,
  }) : super(RoutePlannerState()) {
    //loadNextPage(isRefresh: true);
    initialPlannerLoad();
  }

  void setUserLocation(LatLng? location) {
    state = state.copyWith(userLocation: location);
  }

  // Future<void> validateplanificadorEvent({
  //   required String idUsuarioResponsable,
  // }) async {
  //   try {
  //     final form = {
  //       "ID_USUARIO_RESPONSABLE": idUsuarioResponsable,
  //     };

  //     const endPoint = '/evento/validar-planificador-evento';

  //     final request = await client.post(
  //       endPoint,
  //       data: form,
  //     );
  //     log(request.toString());
  //     if (request.data['status'] == true) {
  //       state = state.copyWith(
  //         isValidatePlanner: true,
  //         validationMessagePlanner: request.data['message'],
  //       );
  //       return;
  //     }
  //     state = state.copyWith(
  //       isValidatePlanner: false,
  //       validationMessagePlanner: request.data['message'],
  //     );
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

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

  Future<void> onChangeNotIsActiveSearchSinRefresh() async {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
    //loadNextPage(isRefresh: true);
    //}
  }

  void onSelectedFilter(FilterOption opt, bool isMulti) {
    if (opt.type == 'DISTANCIA') {
      state = state.copyWith(
          selectedDistanceFilter:
              DistanceFilter(valor: opt.id, descripcion: opt.name));
    }

    bool found = false;

    print('options id: ${opt.id}');
    print('options name: ${opt.name}');
    print('options title: ${opt.title}');
    print('options type: ${opt.type}');

    // Usando una lista mutable para actualizar los filtros.
    List<FilterOption> updatedFilters = List.from(state.filters);

    // Limpiar filtros dependientes en cascada
    if (opt.type == 'DEPARTAMENTO') {
      // Si se cambia departamento, limpiar provincia y distrito
      updatedFilters.removeWhere(
          (filter) => filter.type == 'PROVINCIA' || filter.type == 'DISTRITO');
      print('🧹 Limpiando PROVINCIA y DISTRITO al cambiar DEPARTAMENTO');
    } else if (opt.type == 'PROVINCIA') {
      // Si se cambia provincia, limpiar distrito
      updatedFilters.removeWhere((filter) => filter.type == 'DISTRITO');
      print('🧹 Limpiando DISTRITO al cambiar PROVINCIA');
    }

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

          var optNew = FilterOption(
              id: joinList, type: opt.type, title: opt.title, name: joinList);
          updatedFilters[i] = optNew;
        } else {
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

        var optNew = FilterOption(
            id: joinList, type: opt.type, title: opt.title, name: joinList);
        updatedFilters.add(optNew);
      } else {
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
    return state.selectedItems
        .indexWhere((CompanyLocalRoutePlanner d) => d.key == key);
  }

  bool onReorder(
      Key item, Key newPosition, List<CompanyLocalRoutePlanner> list) {
    int draggingIndex = indexOfKey(item);
    int newPositionIndex = indexOfKey(newPosition);

    final draggedItem = state.selectedItems[draggingIndex];

    final newListSelectedItems = [...state.selectedItems];

    newListSelectedItems.removeAt(draggingIndex);
    newListSelectedItems.insert(newPositionIndex, draggedItem);

    state = state.copyWith(selectedItems: newListSelectedItems);

    return true;
  }

  Future<void> setSelectedItemsOrder(
      List<CompanyLocalRoutePlanner> selectedItemsOrder) async {
    state = state.copyWith(
      selectedItems: selectedItemsOrder,
    );
  }

  Future<void> initialOrderkey() async {
    List<CompanyLocalRoutePlanner> newListItemsSelected = [];
    List<CompanyLocalRoutePlanner> oldListItemsSelected = state.selectedItems;

    for (var i = 0; i < oldListItemsSelected.length; i++) {
      CompanyLocalRoutePlanner local = oldListItemsSelected[i];
      local.key = ValueKey(i);

      newListItemsSelected.add(local);
    }

    state = state.copyWith(selectedItems: newListItemsSelected);
  }

  Future<void> initialPlannerLoad() async {
    state = state.copyWith(isLoading: true);

    // Cargar filtros de horario
    List<FilterOption> filtersHorario = await loadFieldFilterHorario() ?? [];

    // Cargar filtros de distancia (esto agregará el default a filtersSuccess)
    List<FilterOption> filtersDistance = await loadDistanceFilters();

    List<FilterOption> initialFilters = [...filtersHorario, ...filtersDistance];

    // Auto-setear filtro de responsable si el usuario NO es admin
    if (user != null && !user!.isAdmin) {
      // Agregar filtro de responsable automáticamente para vendedores
      final responsableFilter = FilterOption(
        id: user!.code,
        type: 'ID_USUARIO_RESPONSABLE',
        title: 'Responsable',
        name: user!.name,
      );
      initialFilters.add(responsableFilter);
      print('✅ Filtro de responsable auto-seteado para vendedor: ${user!.name}');
    }

    state = state.copyWith(
        filtersSuccess: initialFilters,
        filters: initialFilters,
        selectedItems: [],
        isActiveSearch: false,
        textSearch: '',
        isLoading: false);

    await loadNextPage(isRefresh: true);
  }

  Future<List<FilterOption>> loadDistanceFilters() async {
    try {
      final filters = await routePlannerRepository.getDistanceFilters();

      // Actualizamos estado de las opciones disponibles sin seleccionar ninguno
      state = state.copyWith(
        distanceFilters: filters,
        selectedDistanceFilter: null,
      );

      // No retornamos ningún filtro por defecto
      return [];
    } catch (e) {
      print('Error loading distance filters: $e');
      // En caso de error, no establecer ningún filtro por defecto
      state = state.copyWith(
        distanceFilters: [],
        selectedDistanceFilter: null,
      );
      return [];
    }
  }

  void onChangeDistanceFilter(DistanceFilter filter) {
    List<FilterOption> currentFilters = [...state.filtersSuccess];

    // Remover filtro de distancia anterior si existe
    currentFilters.removeWhere((f) => f.type == 'DISTANCIA');

    // Agregar nuevo filtro si no es "Todos"
    if (!filter.isAll) {
      currentFilters.add(FilterOption(
        id: filter.valor,
        name: filter.descripcion,
        title: 'Distancia',
        type: 'DISTANCIA',
      ));
    }

    state = state.copyWith(
      selectedDistanceFilter: filter,
      filters: currentFilters, // Update temp filters too
      filtersSuccess: currentFilters,
    );
    loadNextPage(isRefresh: true);
  }

  void clearValues() async {
    state = state.copyWith(
      filtersSuccess: [],
      filters: [],
      selectedItems: [],
      isActiveSearch: false,
      textSearch: '',
      isLoading: false,
    );
  }

  Future<void> onDeleteAllFilter() async {
    List<FilterOption> remainingFilters = [];

    // Si no es admin, mantener el filtro de responsable
    if (user != null && !user!.isAdmin) {
      remainingFilters = state.filtersSuccess
          .where((filter) => filter.type == 'ID_USUARIO_RESPONSABLE')
          .toList();
    }

    state = state.copyWith(
        filters: remainingFilters,
        filtersSuccess: remainingFilters,
        selectedDistanceFilter: null);

    loadNextPage(isRefresh: true);
  }

  void onDeleteFilter(int index) {
    var filterSuccessNew = [...state.filtersSuccess];
    var deletedFilter = filterSuccessNew[index];

    // Evitar que vendedores eliminen su propio filtro de responsable
    if (user != null && !user!.isAdmin && deletedFilter.type == 'ID_USUARIO_RESPONSABLE') {
      print('⚠️ Los vendedores no pueden eliminar el filtro de responsable');
      return;
    }

    filterSuccessNew.removeAt(index);

    // Si se elimina el filtro de distancia, resetear el selectedDistanceFilter
    // Combinar ambas actualizaciones en una sola para evitar que el filtro quede activo
    state = state.copyWith(
        filters: filterSuccessNew,
        filtersSuccess: filterSuccessNew,
        selectedDistanceFilter: deletedFilter.type == 'DISTANCIA'
            ? null
            : state.selectedDistanceFilter);
    loadNextPage(isRefresh: true);
  }

  void onDeleteFilterByType(String type) {
    state = state.copyWith(
        filters: state.filtersSuccess
            .where((filter) => filter.type != type)
            .toList(),
        filtersSuccess: state.filtersSuccess
            .where((filter) => filter.type != type)
            .toList());

    if (type == 'DISTANCIA') {
      state = state.copyWith(selectedDistanceFilter: null);
    }

    loadNextPage(isRefresh: true);
  }

  Future<List<DropdownOption>> loadFilterActivity() async {
    //state = state.copyWith(isLoading: true);

    List<FilterActivity> filters =
        await routePlannerRepository.getFilterActivities();

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
      options.add(DropdownOption(id: filter.valor, name: filter.descripcion));
    }

    return options;
  }

  Future<Coordenada> cargarCoordena() async {
    Coordenada coors = await routePlannerRepository.getCoordenadas();
    return coors;
  }

  Future<List<DropdownOption>> loadFilterDistanceOptions() async {
    final filters = state.distanceFilters;
    List<DropdownOption> options = [DropdownOption(id: '', name: 'Selecciona')];

    for (final filter in filters) {
      options.add(DropdownOption(
        id: filter.valor,
        name: filter.descripcion,
      ));
    }

    return options;
  }

  Future<List<DropdownOption>> loadFilterHorarioTrabajo() async {
    //state = state.copyWith(isLoading: true);

    List<FilterHorarioTrabajo> filters =
        await routePlannerRepository.getFilterHorarioTrabajo();

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
      options.add(DropdownOption(
          id: filter.hrtrIdHorarioTrabajo!, name: filter.hrtrDescricion!));
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
      options.add(DropdownOption(
          id: filter.userreportCodigo, name: filter.userreportName));
    }

    return options;
  }

  Future<List<DropdownOption>> loadFilterTypeOpportunity() async {
    //state = state.copyWith(isLoading: true);

    // List<Map<String, dynamic>> filters = [
    //   {"id": "01", "name": "Leads Abiertos"},
    //   {"id": "02", "name": "Contactado"},
    //   {"id": "03", "name": "Oferta Enviada"},
    //   {"id": "04", "name": "En Negociación"}
    // ];

    final filters =
        await resourceDetailsRepository.getResourceDetailsVisibleByGroup(
            idCodigo: "01,02,03,04", idGroup: "05");
    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
      options.add(
        DropdownOption(
          id: filter.recdCodigo,
          name: filter.recdNombre,
        ),
      );
    }

    return options;
  }

  void onCheckItem(CompanyLocalRoutePlanner company) {
    print('onCheckItem localCodigo: ${company.localCodigo}');
    print('onCheckItem ruc: ${company.ruc}');
    bool exists = state.selectedItems.any((item) =>
        item.ruc == company.ruc && item.localCodigo == company.localCodigo);
    print(exists);
    print('onCheckItem total: ${state.selectedItems.length}');
    if (!exists) {
      state = state.copyWith(selectedItems: [...state.selectedItems, company]);
    } else {
      print('eliminar item');
      List<CompanyLocalRoutePlanner> newItems = [...state.selectedItems];

      newItems.removeWhere((item) =>
          item.ruc == company.ruc && item.localCodigo == company.localCodigo);
      //newItems.remove(company);
      print('total elimnado: ${newItems.length} ');
      state = state.copyWith(selectedItems: newItems);
    }
  }

  Future<List<FilterOption>?> loadFieldFilterHorario() async {
    ValidateHorarioTrabajoResponse validate =
        await routePlannerRepository.getHorarioTrabajo();

    if (validate.status) {
      List<FilterOption> filtersA = [...state.filtersSuccess];

      bool exists =
          filtersA.any((filter) => filter.type == 'HRTR_ID_HORARIO_TRABAJO');

      if (!exists) {
        var nuevo = FilterOption(
            id: validate.data?.idHorarioTrabajo ?? '',
            type: 'HRTR_ID_HORARIO_TRABAJO',
            title: 'Horario de trabajo',
            name: validate.data?.descripcion ?? '');

        List<FilterOption> filtersb = [nuevo, ...state.filtersSuccess];

        return filtersb;
      }
    }
    return null;
  }

  Future<void> loadFilterHorario() async {
    List<FilterOption>? validate = await loadFieldFilterHorario();

    if (validate != null) {
      state = state.copyWith(filtersSuccess: validate, filters: validate);
    }

    /*ValidateHorarioTrabajoResponse validate =
        await routePlannerRepository.getHorarioTrabajo();

    if (validate.status) {
      List<FilterOption> filtersA = [...state.filtersSuccess];

      // Verifica si ya existe un filtro con el mismo id
      bool exists =
          filtersA.any((filter) => filter.type == 'HRTR_ID_HORARIO_TRABAJO');

      print('EXIST: ${exists}');
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
    } */
  }

  Future<List<DropdownOption>> loadFilterCodigoPostal(String search) async {
    //state = state.copyWith(isLoading: true);

    List<FilterCodigoPostal> filters =
        await routePlannerRepository.getFilterCodigoPostal(search: search);

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
      options.add(DropdownOption(
          id: filter.localCodigoPostal, name: filter.localCodigoPostal));
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
    state = state.copyWith(dateTimeInitial: dateIni, dateTimeEnd: datetEnd);
  }

  Future<ValidateEventPlannerResponse> validatePlanner(
      String idHorario, String idResponsable) async {
    //state = state.copyWith(isLoading: true);

    final event = {
      'PLRT_ID_HORARIO_TRABAJO': idHorario,
      'EVENTOS_PLANIFICADOR_RUTA':
          List<dynamic>.from(state.selectedItems.map((x) => x.toJson())),

      /// [Planificador]
      'ID_USUARIO_RESPONSABLE': idResponsable,
    };
    log('This is the send in the ID_USUARIO_RESPONSABLE $event ');

    ValidateEventPlannerResponse validate =
        await routePlannerRepository.validateEventPlanner(event);
    log('''
    VALIDATE RESPONSE
        ${validate.message}
        ${validate.status}
        ${validate.type}
     ''');

    return validate;
  }

  void sendLoadFilter() {
    state = state.copyWith(filtersSuccess: state.filters, selectedItems: []);
    loadNextPage(isRefresh: true);
  }

  void updateFilters() {
    state = state.copyWith(filtersSuccess: state.filters, selectedItems: []);
  }

  Future<List<DropdownOption>> loadFilterRuc(String search) async {
    //state = state.copyWith(isLoading: true);

    List<FilterRucRazonSocial> filters =
        await routePlannerRepository.getFilterRucRazonSocial(search: search);

    List<DropdownOption> options = [];

    options.add(DropdownOption(id: '', name: 'Selecciona'));

    for (final filter in filters) {
      options.add(DropdownOption(
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
      options.add(DropdownOption(
          id: filter.razonComercial,
          name: filter.razonComercial,
          subTitle: filter.razon,
          secundary: filter.tipoCliente));
    }

    return options;
  }

  // Método para cargar todas las opciones de filtro en paralelo
  Future<void> loadAllFilterOptions() async {
    try {
      final Map<String, List<DropdownOption>> cache = {};

      // Cargar filtros de DropdownOption en paralelo
      final dropdownResults = await Future.wait([
        loadFilterHorarioTrabajo(),
        loadFilterActivity(),
        loadFilterDistanceOptions(),
        loadFilterResponsable(),
        loadFilterTypeOpportunity(),
      ]);

      cache['HRTR_ID_HORARIO_TRABAJO'] = dropdownResults[0];
      cache['ULTIMAS_VISITAS'] = dropdownResults[1];
      cache['DISTANCIA'] = dropdownResults[2];
      cache['ID_USUARIO_RESPONSABLE'] = dropdownResults[3];
      cache['ID_TIPO_OPORTUNIDAD'] = dropdownResults[4];

      // Cargar filtros de catálogo en paralelo
      final catalogResults = await Future.wait([
        resourceDetailsRepository.getResourceDetailsVisibleByGroup(
            idCodigo: '', idGroup: '18'), // ESTADO
        resourceDetailsRepository.getResourceDetailsVisibleByGroup(
            idCodigo: '', idGroup: '02'), // TIPOCLIENTE
        resourceDetailsRepository.getResourceDetailsVisibleByGroup(
            idCodigo: '', idGroup: '03'), // ESTADO_CRM
        resourceDetailsRepository.getResourceDetailsVisibleByGroup(
            idCodigo: '', idGroup: '04'), // CALIFICACION
        resourceDetailsRepository.getResourceDetailsVisibleByGroup(
            idCodigo: '', idGroup: '16'), // ID_RUBRO
      ]);

      // ESTADO (18)
      List<DropdownOption> estadoOptions = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      for (final filter in catalogResults[0]) {
        estadoOptions.add(
            DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
      }
      cache['ESTADO'] = estadoOptions;

      // TIPOCLIENTE (02)
      List<DropdownOption> tipoClienteOptions = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      for (final filter in catalogResults[1]) {
        tipoClienteOptions.add(
            DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
      }
      cache['TIPOCLIENTE'] = tipoClienteOptions;

      // ESTADO_CRM (03)
      List<DropdownOption> estadoCrmOptions = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      for (final filter in catalogResults[2]) {
        estadoCrmOptions.add(
            DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
      }
      cache['ESTADO_CRM'] = estadoCrmOptions;

      // CALIFICACION (04)
      List<DropdownOption> calificacionOptions = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      for (final filter in catalogResults[3]) {
        calificacionOptions.add(
            DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
      }
      cache['CALIFICACION'] = calificacionOptions;

      // ID_RUBRO (16)
      List<DropdownOption> rubroOptions = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      for (final filter in catalogResults[4]) {
        rubroOptions.add(
            DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
      }
      cache['ID_RUBRO'] = rubroOptions;

      state = state.copyWith(filterOptionsCache: cache);
      print('✅ Cache de filtros del planificador cargado exitosamente.');
    } catch (e) {
      print('❌ Error al cargar opciones de filtro del planificador: $e');
    }
  }

  // Método para obtener opciones de filtro desde el cache o cargarlas
  Future<List<DropdownOption>> getFilterOptions(String type,
      {String search = ''}) async {
    // Si hay cache y el tipo está en cache
    if (state.filterOptionsCache != null &&
        state.filterOptionsCache!.containsKey(type)) {
      print('✅ Usando cache para filtro: $type');
      List<DropdownOption> cachedOptions = state.filterOptionsCache![type]!;

      // Si hay búsqueda, filtrar en cliente
      if (search.isNotEmpty) {
        return cachedOptions
            .where((option) =>
                option.name.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
      return cachedOptions;
    }

    // Si no hay cache, cargar directamente
    print('⚠️ Cache no disponible, cargando filtro: $type');
    switch (type) {
      case 'HRTR_ID_HORARIO_TRABAJO':
        return await loadFilterHorarioTrabajo();
      case 'ULTIMAS_VISITAS':
        return await loadFilterActivity();
      case 'DISTANCIA':
        return await loadFilterDistanceOptions();
      case 'ESTADO':
        final filters = await resourceDetailsRepository
            .getResourceDetailsVisibleByGroup(idCodigo: '', idGroup: '18');
        List<DropdownOption> options = [
          DropdownOption(id: '', name: 'Selecciona')
        ];
        for (final filter in filters) {
          options.add(
              DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
        }
        return options;
      case 'TIPOCLIENTE':
        final filters = await resourceDetailsRepository
            .getResourceDetailsVisibleByGroup(idCodigo: '', idGroup: '02');
        List<DropdownOption> options = [
          DropdownOption(id: '', name: 'Selecciona')
        ];
        for (final filter in filters) {
          options.add(
              DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
        }
        return options;
      case 'ESTADO_CRM':
        final filters = await resourceDetailsRepository
            .getResourceDetailsVisibleByGroup(idCodigo: '', idGroup: '03');
        List<DropdownOption> options = [
          DropdownOption(id: '', name: 'Selecciona')
        ];
        for (final filter in filters) {
          options.add(
              DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
        }
        return options;
      case 'CALIFICACION':
        final filters = await resourceDetailsRepository
            .getResourceDetailsVisibleByGroup(idCodigo: '', idGroup: '04');
        List<DropdownOption> options = [
          DropdownOption(id: '', name: 'Selecciona')
        ];
        for (final filter in filters) {
          options.add(
              DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
        }
        return options;
      case 'ID_USUARIO_RESPONSABLE':
        return await loadFilterResponsable();
      case 'ID_TIPO_OPORTUNIDAD':
        return await loadFilterTypeOpportunity();
      case 'ID_RUBRO':
        final filters = await resourceDetailsRepository
            .getResourceDetailsVisibleByGroup(idCodigo: '', idGroup: '16');
        List<DropdownOption> options = [
          DropdownOption(id: '', name: 'Selecciona')
        ];
        for (final filter in filters) {
          options.add(
              DropdownOption(id: filter.recdCodigo, name: filter.recdNombre));
        }
        return options;
      // Los filtros con búsqueda dinámica no se cachean
      case 'CODIGO_POSTAL':
        return await loadFilterCodigoPostal(search);
      case 'DISTRITO':
        return await loadFilterDistrito(search);
      case 'RUC':
        return await loadFilterRuc(search);
      case 'RAZON_COMERCIAL':
        return await loadFiltecRazonComercial(search);
      default:
        return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<CreateEventPlannerResponse> createEventPlanner(
      Map<dynamic, dynamic> eventLike) async {
    try {
      final eventResponse =
          await routePlannerRepository.createEventPlanner(eventLike);

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
    state = state.copyWith(selectedItems: []);
  }

  // Método para calcular distancia usando fórmula de Haversine
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radio de la Tierra en kilómetros
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c; // Distancia en kilómetros
    return distance;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  // Calcular bounding box basado en ubicación y distancia (km)
  Map<String, double>? _calculateBoundingBox(
      LatLng userLocation, double distanceKm) {
    if (distanceKm <= 0) return null;

    // 1 grado de latitud ≈ 111 km
    const double kmPerDegreeLat = 111.0;

    final latDelta = distanceKm / kmPerDegreeLat;
    final latNorte = userLocation.latitude + latDelta;
    final latSur = userLocation.latitude - latDelta;

    final latRad = userLocation.latitude * (pi / 180);
    final kmPerDegreeLng = kmPerDegreeLat * cos(latRad);

    final lngDelta = distanceKm / kmPerDegreeLng;
    final lngEste = userLocation.longitude + lngDelta;
    final lngOeste = userLocation.longitude - lngDelta;

    // IMPORTANTE: El backend espera LAT_MIN como valor más alto (norte) y LAT_MAX como más bajo (sur)
    // Esto es porque en coordenadas negativas (sur del ecuador), -11.890 > -11.980
    // Para LNG: LNG_MIN es el menos negativo (este) y LNG_MAX es el más negativo (oeste)
    return {
      'LAT_MIN':
          latNorte, // El valor menos negativo (más alto numéricamente, norte)
      'LAT_MAX': latSur, // El valor más negativo (más bajo numéricamente, sur)
      'LNG_MIN': lngEste, // El valor menos negativo (este)
      'LNG_MAX': lngOeste, // El valor más negativo (oeste)
    };
  }

  // Filtrar locales por distancia usando la ubicación del state
  List<CompanyLocalRoutePlanner> filterLocalesByDistance(
      List<CompanyLocalRoutePlanner> locales) {
    // Si el filtro es "Todos" (valor 0), retornar todos los locales
    if (state.selectedDistanceFilter == null ||
        state.selectedDistanceFilter!.isAll) {
      return locales;
    }

    // Si no hay ubicación disponible, retornar todos los locales
    if (state.userLocation == null) {
      print('⚠️ No hay ubicación disponible para filtrar por distancia');
      return locales;
    }

    try {
      final location = state.userLocation!;
      final maxDistance = state.selectedDistanceFilter!.distanceValue;

      // Filtrar locales que estén dentro del radio
      return locales.where((local) {
        try {
          final localLat = double.parse(local.localCoordenadasLatitud);
          final localLng = double.parse(local.localCoordenadasLongitud);

          final distance = _calculateDistance(
            location.latitude,
            location.longitude,
            localLat,
            localLng,
          );

          return distance <= maxDistance;
        } catch (e) {
          // Si hay error parseando coordenadas, excluir el local
          print('Error parsing coordinates for local: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error filtering by distance: $e');
      // En caso de error, retornar todos los locales
      return locales;
    }
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

    print('sLimit x: $sLimit');
    print('sOffset x: $sOffset');

    // Calcular bounding box usando la ubicación ya obtenida (solo una vez al inicio)
    Map<String, double>? boundingBox;
    if (state.selectedDistanceFilter != null &&
        !state.selectedDistanceFilter!.isAll &&
        state.userLocation != null) {
      final distance = state.selectedDistanceFilter!.distanceValue;
      boundingBox = _calculateBoundingBox(state.userLocation!, distance);
      print(
          '📍 Bounding box calculado: LAT_MIN=${boundingBox?['LAT_MIN']}, LAT_MAX=${boundingBox?['LAT_MAX']}, LNG_MIN=${boundingBox?['LNG_MIN']}, LNG_MAX=${boundingBox?['LNG_MAX']}');
    }

    // Consultar al backend con bounding box (si aplica)
    final locales = await routePlannerRepository.getCompanyLocals(
      search: search,
      limit: sLimit,
      offset: sOffset,
      filters: state.filtersSuccess,
      latMin: boundingBox?['LAT_MIN'],
      latMax: boundingBox?['LAT_MAX'],
      lngMin: boundingBox?['LNG_MIN'],
      lngMax: boundingBox?['LNG_MAX'],
    );

    // Aplicar filtrado adicional por distancia en el cliente (filtrado preciso)
    final filteredLocales = filterLocalesByDistance(locales);

    if (filteredLocales.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true, locales: []);

      if (!state.isLastPage) {
        if (isRefresh) {
          state = state.copyWith(
            isLoading: false,
            isLastPage: true,
          );
        } else {
          state = state.copyWith(
            isReload: false,
            isLastPage: true,
          );
        }
      } else {
        if (isRefresh) {
          state =
              state.copyWith(isLoading: false, isLastPage: true, locales: []);
        } else {
          state =
              state.copyWith(isReload: false, isLastPage: true, locales: []);
        }
      }

      //state = state.copyWith(isLoading: false, locales: []);
      return;
    } else {
      int newOffset;
      List<CompanyLocalRoutePlanner> newLocales;

      if (isRefresh) {
        newOffset = 0;
        newLocales = filteredLocales;
      } else {
        //newOffset = state.offset + 10;
        newOffset = sOffset;
        newLocales = [...state.locales, ...filteredLocales];
      }

      print('Offset: $newOffset');

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
  final String? validationMessagePlanner;
  final bool? isValidatePlanner;
  final List<DistanceFilter> distanceFilters;
  final DistanceFilter? selectedDistanceFilter;
  final LatLng? userLocation;
  // Cache de opciones de filtro precargadas
  final Map<String, List<DropdownOption>>? filterOptionsCache;

  RoutePlannerState(
      {this.isLastPage = false,
      this.isReload = false,
      this.isValidatePlanner,
      this.validationMessagePlanner,
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
      this.dateTimeInitial = '',
      this.dateTimeEnd = '',
      this.distanceFilters = const [],
      this.selectedDistanceFilter,
      this.userLocation,
      this.filterOptionsCache});

  RoutePlannerState copyWith({
    bool? isLastPage,
    bool? isReload,
    int? limit,
    int? offset,
    String? validationMessagePlanner,
    bool? isValidatePlanner,
    bool? isLoading,
    bool? isActiveSearch,
    String? textSearch,
    List<CompanyLocalRoutePlanner>? locales,
    //List<CompanyLocalRoutePlanner>? localesOrderTemp,
    List<FilterOption>? filters,
    List<FilterOption>? filtersSuccess,
    List<CompanyLocalRoutePlanner>? selectedItems,
    String? dateTimeInitial,
    String? dateTimeEnd,
    List<DistanceFilter>? distanceFilters,
    Object? selectedDistanceFilter = const _Undefined(),
    Object? userLocation = const _Undefined(),
    Map<String, List<DropdownOption>>? filterOptionsCache,
  }) =>
      RoutePlannerState(
        isLastPage: isLastPage ?? this.isLastPage,
        validationMessagePlanner: this.validationMessagePlanner,
        isValidatePlanner: isValidatePlanner ?? this.isValidatePlanner,
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
        distanceFilters: distanceFilters ?? this.distanceFilters,
        selectedDistanceFilter: selectedDistanceFilter is _Undefined
            ? this.selectedDistanceFilter
            : selectedDistanceFilter as DistanceFilter?,
        userLocation: userLocation is _Undefined
            ? this.userLocation
            : userLocation as LatLng?,
        filterOptionsCache: filterOptionsCache ?? this.filterOptionsCache,
      );
}

import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/auth/domain/entities/user.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/resource-detail/domain/repositories/resource_details_repository.dart';
import 'package:crm_app/features/resource-detail/presentation/providers/resource_details_repository_provider.dart';
import 'package:crm_app/features/route-planner/domain/entities/distance_filter.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_option.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import '../../domain/domain.dart';

import 'companies_repository_provider.dart';

final companiesProvider =
    StateNotifierProvider<CompaniesNotifier, CompaniesState>((ref) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  final resourceDetailsRepository =
      ref.watch(resourceDetailsRepositoryProvider);
  final user = ref.read(authProvider);
  return CompaniesNotifier(
    companiesRepository: companiesRepository,
    resourceDetailsRepository: resourceDetailsRepository,
    user: user.user,
    ref: ref,
  );
});

/// [Para agilizar el desarroollo de los clientes incorpore directamente DIO en el providoer state, esto de momento en cuanto haya la oportunidad se necesatara realizar un refactor]
class CompaniesNotifier extends StateNotifier<CompaniesState> {
  final CompaniesRepository companiesRepository;
  final ResourceDetailsRepository resourceDetailsRepository;
  final Ref ref;
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
    required this.resourceDetailsRepository,
    required this.ref,
    this.user,
  }) : super(CompaniesState()) {
    client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer ${user?.token}'},
        baseUrl: Environment.apiUrl,
      ),
    );
    // NO cargar datos aquí, se hará después de establecer filtros por defecto
    // loadNextPage(isRefresh: true);
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

  void setUserLocation(LatLng location) {
    state = state.copyWith(userLocation: location);
  }

  // Filter Methods

  void onSelectedFilter(FilterOption opt, bool isMulti) {
    // Ignorar filtros de distancia (se manejan de forma independiente)
    if (opt.type == 'DISTANCIA') {
      return;
    }

    bool found = false;
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

          if (joinList.isEmpty) {
            updatedFilters.removeAt(i);
            found = true;
            break;
          }

          var optNew = FilterOption(
              id: joinList,
              type: opt.type,
              title: opt.title,
              name: joinList); // Name might need adjustment for multi
          updatedFilters[i] = optNew;
        } else {
          updatedFilters[i] = opt;
        }
        found = true;
        break;
      }
    }

    if (!found) {
      updatedFilters.add(opt);
    }

    state = state.copyWith(filters: updatedFilters);
  }

  void updateFilters() {
    state = state.copyWith(filtersSuccess: state.filters);
    loadNextPage(isRefresh: true);
  }

  void onDeleteAllFilter() {
    state = state.copyWith(filters: [], filtersSuccess: []);

    loadNextPage(isRefresh: true);
  }

  void onDeleteFilter(int index) {
    var filterSuccessNew = [...state.filtersSuccess];
    var deletedFilter = filterSuccessNew[index];

    filterSuccessNew.removeAt(index);

    // Si se elimina el filtro de distancia, resetear el selectedDistanceFilter
    // Combinar ambas actualizaciones en una sola para evitar que el filtro quede activo

    if (deletedFilter.type == 'DISTANCIA') {
      state = state.setSelectedDistanceFilterNull().copyWith(
            filters: filterSuccessNew,
            filtersSuccess: filterSuccessNew,
          );
    } else {
      state = state.copyWith(
        filters: filterSuccessNew,
        filtersSuccess: filterSuccessNew,
        selectedDistanceFilter: state.selectedDistanceFilter,
      );
    }

    loadNextPage(isRefresh: true);
  }

  void onDeleteFilterByType(String type) {
    state = state.copyWith(
        filters: state.filters.where((filter) => filter.type != type).toList());

    if (type == 'DISTANCIA') {
      state = state.setSelectedDistanceFilterNull();
    }

    loadNextPage(isRefresh: true);
  }

  // Distance Logic
  void onChangeDistanceFilter(DistanceFilter filter) {
    // Solo actualizar el filtro de distancia seleccionado
    // NO agregarlo a la lista de filtros (se maneja de forma independiente)
    state = state.copyWith(
      selectedDistanceFilter: filter,
    );

    loadNextPage(isRefresh: true);
  }

  // Cambiar filtro de distancia sin recargar (útil para configuración inicial)
  void onChangeDistanceFilterWithoutReload(DistanceFilter filter) {
    state = state.copyWith(
      selectedDistanceFilter: filter,
    );
  }

  // Calcular distancia entre dos puntos usando la fórmula de Haversine
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

  // Filtrar empresas por distancia usando la ubicación del state
  List<Company> filterCompaniesByDistance(List<Company> companies) {
    // Si el filtro es "Todos" (valor 0), retornar todas las empresas
    if (state.selectedDistanceFilter == null ||
        state.selectedDistanceFilter!.isAll) {
      return companies;
    }

    // Si no hay ubicación disponible, retornar todas las empresas
    if (state.userLocation == null) {
      print('⚠️ No hay ubicación disponible para filtrar por distancia');
      return companies;
    }

    try {
      final location = state.userLocation!;
      final maxDistance = state.selectedDistanceFilter!.distanceValue;

      // Filtrar empresas que estén dentro del radio
      return companies.where((company) {
        try {
          // Usar localCoordenadas (formato: ["lng,lat", "lng,lat", ...])
          if (company.localCoordenadas == null ||
              company.localCoordenadas!.isEmpty) {
            // Si no hay coordenadas, excluir la empresa
            return false;
          }

          // Verificar si al menos una de las coordenadas está dentro del radio
          for (final coordString in company.localCoordenadas!) {
            try {
              // Parsear el string "lng,lat"
              final parts = coordString.split(',');
              if (parts.length != 2) continue;

              final lng = double.parse(parts[0].trim());
              final lat = double.parse(parts[1].trim());

              final distance = _calculateDistance(
                location.latitude,
                location.longitude,
                lat,
                lng,
              );

              // Si al menos un local está dentro del radio, incluir la empresa
              if (distance <= maxDistance) {
                return true;
              }
            } catch (e) {
              // Error parseando esta coordenada específica, probar la siguiente
              continue;
            }
          }

          // Ninguna coordenada está dentro del radio
          return false;
        } catch (e) {
          // Si hay error general, excluir la empresa
          print('Error filtering company ${company.ruc}: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error filtering by distance: $e');
      // En caso de error, retornar todas las empresas
      return companies;
    }
  }

  // Método para calcular bounding box basado en ubicación y distancia
  Map<String, double>? _calculateBoundingBox(
      LatLng userLocation, double distanceKm) {
    if (distanceKm <= 0) return null;

    // 1 grado de latitud ≈ 111 km
    const double kmPerDegreeLat = 111.0;

    // Calcular límites de latitud
    final latDelta = distanceKm / kmPerDegreeLat;
    final latNorte = userLocation.latitude + latDelta;
    final latSur = userLocation.latitude - latDelta;

    // 1 grado de longitud ≈ 111 km * cos(latitud)
    final latRad = userLocation.latitude * (pi / 180);
    final kmPerDegreeLng = kmPerDegreeLat * cos(latRad);

    // Calcular límites de longitud
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

  // Loaders for Bottom Sheet
  Future<List<DropdownOption>> loadFilterRubro() async {
    try {
      final result = await resourceDetailsRepository.getResourceDetailsByGroup(
          idGroup: '16');

      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(result
          .map((e) => DropdownOption(id: e.recdCodigo, name: e.recdNombre)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterCalificacion() async {
    try {
      final result = await resourceDetailsRepository
          .getResourceDetailsVisibleByGroup(idGroup: '04');

      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(result
          .map((e) => DropdownOption(id: e.recdCodigo, name: e.recdNombre)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterResponsable() async {
    try {
      final result = await companiesRepository.getFilterResponsable();

      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(result.map((e) =>
          DropdownOption(id: e.userreportCodigo, name: e.userreportName)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterActividad() async {
    try {
      final result = await companiesRepository.getFilterActividad();
      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(
          result.map((e) => DropdownOption(id: e.valor, name: e.descripcion)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterDepartamento(String search) async {
    try {
      final result =
          await companiesRepository.getFilterDepartamento(search: search);
      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(result.map(
          (e) => DropdownOption(id: e.departamento, name: e.departamento)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterProvincia(
      String search, String departamento) async {
    try {
      final result = await companiesRepository.getFilterProvincia(
          search: search, departamento: departamento);
      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(result
          .map((e) => DropdownOption(id: e.provincia, name: e.provincia)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterDistrito(
      String search, String provincia) async {
    try {
      final result = await companiesRepository.getFilterDistrito(
          search: search, provincia: provincia);
      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(
          result.map((e) => DropdownOption(id: e.distrito, name: e.distrito)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterEstado() async {
    try {
      final result = await companiesRepository.getFilterEstado();
      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(
          result.map((e) => DropdownOption(id: e.valor, name: e.descripcion)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  Future<List<DropdownOption>> loadFilterDistanceOptions() async {
    try {
      final result = await companiesRepository.getDistanceFilters();
      state = state.copyWith(distanceFilters: result);

      List<DropdownOption> options = [
        DropdownOption(id: '', name: 'Selecciona')
      ];
      options.addAll(
          result.map((e) => DropdownOption(id: e.valor, name: e.descripcion)));

      return options;
    } catch (e) {
      return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  // Cargar todas las opciones de filtro que no dependen de parámetros
  Future<void> loadAllFilterOptions() async {
    try {
      print('🔄 Cargando todas las opciones de filtro...');
      final Map<String, List<DropdownOption>> cache = {};

      // Cargar todos los filtros en paralelo (incluyendo departamentos)
      final results = await Future.wait([
        loadFilterRubro(),
        loadFilterCalificacion(),
        loadFilterResponsable(),
        loadFilterActividad(),
        loadFilterEstado(),
        loadFilterDistanceOptions(),
        loadFilterDepartamento(''), // Sin búsqueda, todos los departamentos
      ]);

      cache['ID_RUBRO'] = results[0];
      cache['CALIFICACION'] = results[1];
      cache['ID_USUARIO_RESPONSABLE'] = results[2];
      cache['ACTIVIDAD'] = results[3];
      cache['ESTADO'] = results[4];
      cache['DISTANCIA'] = results[5];
      cache['DEPARTAMENTO'] = results[6];

      state = state.copyWith(filterOptionsCache: cache);
      print('✅ Cache de filtros cargado exitosamente');
    } catch (e) {
      // Si hay error, mantener el cache anterior o dejarlo vacío
      print('❌ Error al cargar opciones de filtro: $e');
    }
  }

  // Resetear filtros y establecer valores por defecto
  Future<void> resetFiltersAndSetDefaults() async {
    print('🔄 Reseteando filtros y estableciendo valores por defecto...');

    state = state.copyWith(isLoading: true);

    // Verificar si los filtros ya están cargados (primera vez vs siguientes veces)
    final needsInitialLoad = state.distanceFilters.isEmpty ||
        state.filterOptionsCache?['ESTADO'] == null ||
        (state.filterOptionsCache?['ESTADO'] ?? []).isEmpty;

    // Si es la primera vez, activar loading inicial ANTES de limpiar
    if (needsInitialLoad) {
      state = state.copyWith(isInitializing: true);
    } else {
      // Si no es la primera vez, activar isLoading para mostrar loading mientras se cargan datos
      state = state.copyWith(isInitializing: false);
    }

    // Limpiar todos los filtros primero
    state = state.setSelectedDistanceFilterNull().copyWith(
      filters: [],
      filtersSuccess: [],
    );

    // Cargar filtros solo si no están cargados
    if (needsInitialLoad) {
      await Future.wait([
        loadFilterDistanceOptions(),
        loadFilterEstado(),
      ]);

      // Guardar estado en el cache
      final estadoOptions = await loadFilterEstado();
      final currentCache = Map<String, List<DropdownOption>>.from(
        state.filterOptionsCache ?? {},
      );
      currentCache['ESTADO'] = estadoOptions;
      state = state.copyWith(
          filterOptionsCache: currentCache, isInitializing: false);
    }

    // Establecer filtro de distancia por defecto: "Menor a 5KM" (valor = "5")
    final distanceFilters = state.distanceFilters;
    DistanceFilter? defaultDistanceFilter;

    // Buscar específicamente el filtro con valor "5"
    try {
      defaultDistanceFilter = distanceFilters.firstWhere(
        (filter) => filter.valor == "5",
      );
    } catch (e) {
      // Si no existe, buscar cualquier filtro que NO sea "Todos" (valor "0")
      try {
        defaultDistanceFilter = distanceFilters.firstWhere(
          (filter) => filter.valor != "0" && filter.valor.isNotEmpty,
        );
      } catch (e2) {
        // Si no hay ningún filtro disponible, crear uno por defecto
        defaultDistanceFilter =
            DistanceFilter(valor: "0", descripcion: "Todos");
      }
    }

    // Establecer filtro de Estado por defecto: "Activo"
    final estadoOptions = state.filterOptionsCache?['ESTADO'] ?? [];
    FilterOption estadoFilter;

    final activoOption = estadoOptions.firstWhere(
      (opt) =>
          opt.name.toLowerCase().contains('activo') ||
          opt.id == "A" ||
          opt.id == "1",
      orElse: () => estadoOptions.isNotEmpty
          ? estadoOptions.first
          : DropdownOption(id: "A", name: "Activo"),
    );

    estadoFilter = FilterOption(
      id: activoOption.id,
      type: "ESTADO",
      title: "Estado",
      name: activoOption.name,
    );

    // Actualizar el estado con los filtros por defecto (SIN cargar empresas aún)
    state = state.copyWith(
      selectedDistanceFilter: defaultDistanceFilter,
      filters: [estadoFilter],
      filtersSuccess: [estadoFilter],
      isInitializing: false, // Desactivar loading inicial
    );

    print(
        '✅ Filtros por defecto establecidos: Distancia=${defaultDistanceFilter.descripcion}, Estado=${estadoFilter.name}');
    print('📌 Esperando ubicación GPS antes de cargar empresas...');

    // NO cargar empresas aquí - se hará después de obtener ubicación GPS
  }

  // Obtener opciones de filtro del cache o cargarlas si no están
  Future<List<DropdownOption>> getFilterOptions(String type,
      {String? searchText}) async {
    // Si está en cache, retornarlo inmediatamente (sin llamada al servidor)
    final cache = state.filterOptionsCache;
    if (cache != null && cache.containsKey(type) && cache[type]!.isNotEmpty) {
      print('✅ Usando cache para filtro: $type');
      var options = cache[type]!;

      // Filtrar del lado del cliente si hay búsqueda
      if (searchText != null && searchText.isNotEmpty) {
        options = options
            .where((opt) =>
                opt.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }

      return options;
    }

    // Si no está en cache, cargarlo según el tipo (fallback)
    print('⚠️ Cache no disponible, cargando filtro: $type');
    switch (type) {
      case 'ID_RUBRO':
        return await loadFilterRubro();
      case 'CALIFICACION':
        return await loadFilterCalificacion();
      case 'ID_USUARIO_RESPONSABLE':
        return await loadFilterResponsable();
      case 'ACTIVIDAD':
        return await loadFilterActividad();
      case 'ESTADO':
        return await loadFilterEstado();
      case 'DISTANCIA':
        return await loadFilterDistanceOptions();
      case 'DEPARTAMENTO':
        return await loadFilterDepartamento(searchText ?? '');
      default:
        return [DropdownOption(id: '', name: 'Selecciona')];
    }
  }

  // Obtener provincias (cachear por departamento)
  Future<List<DropdownOption>> getProvinciaOptions(
      String departamentoId, String searchText) async {
    final cache = state.provinciaCache ?? {};

    // Si está en cache para este departamento, usar y filtrar
    if (cache.containsKey(departamentoId) &&
        cache[departamentoId]!.isNotEmpty) {
      print('✅ Usando cache para provincias de: $departamentoId');
      var options = cache[departamentoId]!;

      if (searchText.isNotEmpty) {
        options = options
            .where((opt) =>
                opt.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }

      return options;
    }

    // Cargar provincias del servidor
    print('⚠️ Cargando provincias para: $departamentoId');
    final options = await loadFilterProvincia('', departamentoId);

    // Guardar en cache
    final newCache = Map<String, List<DropdownOption>>.from(cache);
    newCache[departamentoId] = options;
    state = state.copyWith(provinciaCache: newCache);

    // Filtrar si hay búsqueda
    if (searchText.isNotEmpty) {
      return options
          .where((opt) =>
              opt.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    return options;
  }

  // Obtener distritos (cachear por provincia)
  Future<List<DropdownOption>> getDistritoOptions(
      String provinciaId, String searchText) async {
    final cache = state.distritoCache ?? {};

    // Si está en cache para esta provincia, usar y filtrar
    if (cache.containsKey(provinciaId) && cache[provinciaId]!.isNotEmpty) {
      print('✅ Usando cache para distritos de: $provinciaId');
      var options = cache[provinciaId]!;

      if (searchText.isNotEmpty) {
        options = options
            .where((opt) =>
                opt.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }

      return options;
    }

    // Cargar distritos del servidor
    print('⚠️ Cargando distritos para: $provinciaId');
    final options = await loadFilterDistrito('', provinciaId);

    // Guardar en cache
    final newCache = Map<String, List<DropdownOption>>.from(cache);
    newCache[provinciaId] = options;
    state = state.copyWith(distritoCache: newCache);

    // Filtrar si hay búsqueda
    if (searchText.isNotEmpty) {
      return options
          .where((opt) =>
              opt.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    return options;
  }

  Future loadNextPage({bool isRefresh = false}) async {
    final search = state.textSearch;

    // Cancelar el debounce anterior si está activo
    //if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (isRefresh) {
      // Permitir refresh incluso si ya está cargando (para evitar que quede bloqueado)
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

    try {
      // Calcular bounding box si hay filtro de distancia activo
      Map<String, double>? boundingBox;
      if (state.selectedDistanceFilter != null &&
          !state.selectedDistanceFilter!.isAll &&
          state.userLocation != null) {
        final distance = state.selectedDistanceFilter!.distanceValue;
        boundingBox = _calculateBoundingBox(state.userLocation!, distance);
        print(
            '📍 Bounding box calculado: LAT_MIN=${boundingBox?['LAT_MIN']}, LAT_MAX=${boundingBox?['LAT_MAX']}, LNG_MIN=${boundingBox?['LNG_MIN']}, LNG_MAX=${boundingBox?['LNG_MAX']}');
      }

      // Llamada al repositorio con bounding box si existe
      final companies = await companiesRepository.getCompanies(
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
      final filteredCompanies = filterCompaniesByDistance(companies);

      if (filteredCompanies.isEmpty) {
        if (isRefresh) {
          state = state.copyWith(
              isLoading: false, isLastPage: true, offset: 0, companies: []);
        } else {
          state = state.copyWith(isReload: false, isLastPage: true);
        }
        return;
      } else {
        int newOffset;
        List<Company> newCompanies;

        if (isRefresh) {
          newOffset = 0;
          newCompanies = filteredCompanies;
        } else {
          newOffset = sOffset;
          newCompanies = [...state.companies, ...filteredCompanies];
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
    } catch (e) {
      // En caso de error, asegurar que isLoading se ponga en false
      print('❌ Error al cargar empresas: $e');
      if (isRefresh) {
        state = state.copyWith(
            isLoading: false, isLastPage: true, offset: 0, companies: []);
      } else {
        state = state.copyWith(isReload: false, isLastPage: true);
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
  final bool isInitializing;
  final List<Company> companies;
  final bool isActiveSearch;
  final String textSearch;
  final bool isValidateCheckIn;
  final String validationCheckinMessage;

  // Filters
  final List<FilterOption> filters;
  final List<FilterOption> filtersSuccess;
  final List<DistanceFilter> distanceFilters;
  final DistanceFilter? selectedDistanceFilter;
  // Cache de opciones de filtro precargadas
  final Map<String, List<DropdownOption>>? filterOptionsCache;
  // Cache para provincia (por departamento) y distrito (por provincia)
  final Map<String, List<DropdownOption>>? provinciaCache;
  final Map<String, List<DropdownOption>>? distritoCache;
  // Ubicación del usuario (obtenida una vez al inicio)
  final LatLng? userLocation;

  CompaniesState(
      {this.isLastPage = false,
      this.isReload = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isInitializing = true,
      this.isActiveSearch = false,
      this.isValidateCheckIn = false,
      this.validationCheckinMessage = '',
      this.textSearch = '',
      this.companies = const [],
      this.filters = const [],
      this.filtersSuccess = const [],
      this.distanceFilters = const [],
      this.selectedDistanceFilter,
      this.filterOptionsCache,
      this.provinciaCache,
      this.distritoCache,
      this.userLocation});

  CompaniesState setSelectedDistanceFilterNull() => CompaniesState(
        isLastPage: isLastPage,
        isReload: isReload,
        limit: limit,
        offset: offset,
        isLoading: isLoading,
        isInitializing: isInitializing,
        companies: companies,
        isActiveSearch: isActiveSearch,
        textSearch: textSearch,
        isValidateCheckIn: isValidateCheckIn,
        validationCheckinMessage: validationCheckinMessage,
        filters: filters,
        filtersSuccess: filtersSuccess,
        distanceFilters: distanceFilters,
        selectedDistanceFilter: null,
        filterOptionsCache: filterOptionsCache,
        provinciaCache: provinciaCache,
        distritoCache: distritoCache,
        userLocation: userLocation,
      );

  CompaniesState copyWith({
    bool? isLastPage,
    bool? isReload,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isInitializing,
    bool? isActiveSearch,
    String? textSearch,
    bool? isValidateCheckIn,
    String? validationCheckinMessage,
    List<Company>? companies,
    List<FilterOption>? filters,
    List<FilterOption>? filtersSuccess,
    List<DistanceFilter>? distanceFilters,
    DistanceFilter? selectedDistanceFilter,
    Map<String, List<DropdownOption>>? filterOptionsCache,
    Map<String, List<DropdownOption>>? provinciaCache,
    Map<String, List<DropdownOption>>? distritoCache,
    LatLng? userLocation,
  }) =>
      CompaniesState(
          isLastPage: isLastPage ?? this.isLastPage,
          isReload: isReload ?? this.isReload,
          limit: limit ?? this.limit,
          offset: offset ?? this.offset,
          isLoading: isLoading ?? this.isLoading,
          isInitializing: isInitializing ?? this.isInitializing,
          companies: companies ?? this.companies,
          isActiveSearch: isActiveSearch ?? this.isActiveSearch,
          textSearch: textSearch ?? this.textSearch,
          validationCheckinMessage:
              validationCheckinMessage ?? this.validationCheckinMessage,
          isValidateCheckIn: isValidateCheckIn ?? this.isValidateCheckIn,
          filters: filters ?? this.filters,
          filtersSuccess: filtersSuccess ?? this.filtersSuccess,
          distanceFilters: distanceFilters ?? this.distanceFilters,
          selectedDistanceFilter:
              selectedDistanceFilter ?? this.selectedDistanceFilter,
          filterOptionsCache: filterOptionsCache ?? this.filterOptionsCache,
          provinciaCache: provinciaCache ?? this.provinciaCache,
          distritoCache: distritoCache ?? this.distritoCache,
          userLocation: userLocation ?? this.userLocation);
}

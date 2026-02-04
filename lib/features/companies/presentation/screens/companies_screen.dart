import 'dart:async';

import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../widgets/item_company.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/loading_modal.dart';
import '../../../shared/widgets/no_exist_listview.dart';
import '../../../shared/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/companies/presentation/widgets/filter_companies_bottom_sheet.dart';
import 'package:crm_app/features/companies/presentation/widgets/tags_filter_companies.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_option.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/location/presentation/providers/location_provider.dart';
import '../../../shared/shared.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Ejecutar inicialización de forma no bloqueante
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasInitialized) {
        _hasInitialized = true;

        // PASO 1: Resetear filtros y establecer valores por defecto (sin cargar empresas)
        await ref.read(companiesProvider.notifier).resetFiltersAndSetDefaults();

        ref
            .read(companiesProvider.notifier)
            .onChangeNotIsActiveSearchSinRefresh();

        // PASO 2: Obtener ubicación GPS
        await _loadUserLocation();

        // PASO 3: Cargar empresas con filtros y ubicación establecidos
        ref.read(companiesProvider.notifier).loadNextPage(isRefresh: true);
      }
    });
  }

  // Cargar ubicación GPS
  Future<void> _loadUserLocation() async {
    try {
      final location =
          await ref.read(locationProvider.notifier).currentPosition();

      ref.read(companiesProvider.notifier).setUserLocation(location);
      print(
          '📍 Ubicación GPS obtenida: lat=${location.latitude}, lng=${location.longitude}');
    } catch (e) {
      print('⚠️ No se pudo obtener ubicación GPS: $e');

      // Cambiar al filtro "Todos" si no se pudo obtener ubicación
      final currentState = ref.read(companiesProvider);
      final distanceFilters = currentState.distanceFilters;

      if (distanceFilters.isNotEmpty) {
        try {
          // Buscar el filtro "Todos" (valor "0")
          final todosFilter = distanceFilters.firstWhere(
            (filter) => filter.valor == "0",
          );

          // Establecer "Todos" como filtro seleccionado (sin recargar)
          ref
              .read(companiesProvider.notifier)
              .onChangeDistanceFilterWithoutReload(todosFilter);

          // Mostrar snackbar informando
          if (mounted) {
            showSnackbar(
              context,
              'No se pudo obtener tu ubicación. Se mostrarán todas las empresas.',
            );
          }
        } catch (e2) {
          print('⚠️ No se encontró filtro "Todos"');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companiesState = ref.watch(companiesProvider);
    final List<FilterOption> listFiltersSuccess = companiesState.filtersSuccess;

    // Si está inicializando mostrar loading completo
    if (companiesState.isInitializing) {
      return Scaffold(
        drawer: SideMenu(scaffoldKey: scaffoldKey),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Empresas',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              textAlign: TextAlign.center),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const FilterCompaniesBottomSheet(),
                );
              },
              icon: Icon(
                Icons.filter_alt,
                color:
                    listFiltersSuccess.isNotEmpty ? primaryColor : Colors.black,
              ),
            )
          ],
        ),
        body: const LoadingModal(),
      );
    }

    // Pantalla normal cuando ya se cargaron los filtros
    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Empresas',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const FilterCompaniesBottomSheet(),
              );
            },
            icon: Icon(
              Icons.filter_alt,
              color:
                  listFiltersSuccess.isNotEmpty ? primaryColor : Colors.black,
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SearchComponent(),
          const _DistanceFiltersRow(),
          const SizedBox(height: 7),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey[300],
          ),
          listFiltersSuccess.isNotEmpty
              ? const TagRowCompanies()
              : const SizedBox(),
          const Expanded(child: _CompaniesView()),
        ],
      ),
      floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.add,
          callOnPressed: () {
            context.push('/company/new');
          }),
    );
  }
}

class _CompaniesView extends ConsumerStatefulWidget {
  const _CompaniesView();

  @override
  _CompaniesViewState createState() => _CompaniesViewState();
}

class _CompaniesViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        print('CARGANDO MAS');
        ref.read(companiesProvider.notifier).loadNextPage(isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    //String text = ref.watch(companiesProvider).textSearch;
    ref.read(companiesProvider.notifier).loadNextPage(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final companiesState = ref.watch(companiesProvider);
    final isReload = companiesState.isReload;

    if (companiesState.isLoading) {
      return const LoadingModal();
    }

    return companiesState.companies.isNotEmpty
        ? _ListCompanies(
            companies: companiesState.companies,
            onRefreshCallback: _refresh,
            isReload: isReload,
            scrollController: scrollController,
          )
        : NoExistData(
            textCenter: 'No hay empresas registradas',
            onRefreshCallback: _refresh,
            icon: Icons.business);
  }
}

class _ListCompanies extends ConsumerStatefulWidget {
  final List<Company> companies;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;
  final bool isReload;

  const _ListCompanies(
      {required this.companies,
      required this.onRefreshCallback,
      required this.isReload,
      required this.scrollController});

  @override
  _ListCompaniesState createState() => _ListCompaniesState();
}

class _ListCompaniesState extends ConsumerState<_ListCompanies> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.companies.isEmpty
        ? Center(
            child: RefreshIndicator(
                onRefresh: widget.onRefreshCallback,
                key: refreshIndicatorKey,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: widget.onRefreshCallback,
                        child: const Text('Recargar'),
                      ),
                      const Center(
                        child: Text('No hay registros'),
                      ),
                    ],
                  ),
                )),
          )
        : NotificationListener(
            /*onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels + 400 ==
                  scrollInfo.metrics.maxScrollExtent) {
                ref
                    .read(companiesProvider.notifier)
                    .loadNextPage(isRefresh: false);
            }
            return false;
          },*/
            child: RefreshIndicator(
              notificationPredicate: defaultScrollNotificationPredicate,
              onRefresh: widget.onRefreshCallback,
              //key: _refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.companies.length,
                controller: widget.scrollController,
                //physics: const BouncingScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) =>
                    Container(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final company = widget.companies[index];

                  if (index + 1 == widget.companies.length) {
                    if (widget.isReload) {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }

                  return ItemCompany(
                      isEmpresasScreen: true,
                      company: company,
                      callbackOnTap: () {
                        context.push('/company_detail/${company.ruc}');
                      });
                },
              ),
            ),
          );
  }
}

class _DistanceFiltersRow extends ConsumerWidget {
  const _DistanceFiltersRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesState = ref.watch(companiesProvider);
    final selectedFilter = companiesState.selectedDistanceFilter;
    final distanceFilters = companiesState.distanceFilters;

    if (distanceFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...distanceFilters
              .map((filter) => Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: FilterChip(
                        label: Text(
                          filter.descripcion,
                          style: TextStyle(
                            fontWeight: selectedFilter?.valor == filter.valor
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedFilter?.valor == filter.valor
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        selected: selectedFilter?.valor == filter.valor,
                        selectedColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.grey[100],
                        checkmarkColor: Colors.white,
                        onSelected: (bool selected) {
                          ref
                              .read(companiesProvider.notifier)
                              .onChangeDistanceFilter(filter);
                        }),
                  ))
              .toList(),
          const SizedBox(width: 10)
        ],
      ),
    );
  }
}

class _SearchComponent extends ConsumerStatefulWidget {
  const _SearchComponent({super.key});

  @override
  ConsumerState<_SearchComponent> createState() => __SearchComponentState();
}

class __SearchComponentState extends ConsumerState<_SearchComponent> {
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            style: const TextStyle(fontSize: 14.0),
            controller: searchController,
            onChanged: (String value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                ref.read(companiesProvider.notifier).onChangeTextSearch(value);
              });
            },
            onFieldSubmitted: (value) {
              _debounce?.cancel();
              ref.read(companiesProvider.notifier).onChangeTextSearch(value);
            },
            decoration: InputDecoration(
              hintText: 'Buscar empresa...',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 18.0),
              hintStyle: const TextStyle(fontSize: 14.0, color: Colors.black38),
            ),
          ),
          if (ref.watch(companiesProvider).textSearch != "")
            IconButton(
              onPressed: () {
                _debounce?.cancel();
                ref
                    .read(companiesProvider.notifier)
                    .onChangeNotIsActiveSearch();
                searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
        ],
      ),
    );
  }
}

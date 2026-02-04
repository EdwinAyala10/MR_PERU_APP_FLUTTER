import 'package:crm_app/features/companies/presentation/providers/companies_provider.dart';
import 'package:crm_app/features/companies/presentation/widgets/filter_detail_companies.dart';
import 'package:crm_app/features/route-planner/domain/entities/filter_option.dart';
import 'package:crm_app/features/shared/widgets/find_filter_option_by_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterCompaniesBottomSheet extends ConsumerStatefulWidget {
  const FilterCompaniesBottomSheet({super.key});

  @override
  ConsumerState<FilterCompaniesBottomSheet> createState() =>
      _FilterCompaniesBottomSheetState();
}

class _FilterCompaniesBottomSheetState
    extends ConsumerState<FilterCompaniesBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Cargar todas las opciones de filtro al abrir el bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companiesProvider.notifier).loadAllFilterOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight = screenHeight * 0.95;

    return Container(
      height: desiredHeight,
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Filtros Empresas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(companiesProvider.notifier).updateFilters();
                  },
                  child: const Text('Hecho'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: const [
                FilterOptionContainerFil(
                    title: 'Actividad',
                    trailing: 'Selecciona',
                    type: 'ACTIVIDAD'),
                Divider(),
                FilterOptionContainerFil(
                    title: 'Responsable',
                    trailing: 'Selecciona',
                    type: 'ID_USUARIO_RESPONSABLE'),
                Divider(),
                FilterOptionContainerFil(
                    title: 'Departamento',
                    trailing: 'Selecciona',
                    type: 'DEPARTAMENTO',
                    search: true),
                Divider(),
                FilterOptionContainerFil(
                    title: 'Provincia',
                    trailing: 'Selecciona',
                    type: 'PROVINCIA',
                    search: true),
                Divider(),
                FilterOptionContainerFil(
                    title: 'Distrito',
                    trailing: 'Selecciona',
                    type: 'DISTRITO',
                    search: true,
                    multi: true),
                Divider(),
                FilterOptionContainerFil(
                    title: 'Estado', trailing: 'Selecciona', type: 'ESTADO'),
                Divider(),
                FilterOptionContainerFil(
                    title: 'Rubro', trailing: 'Selecciona', type: 'ID_RUBRO'),
                Divider(),
                FilterOptionContainerFil(
                    title: 'Calificación',
                    trailing: 'Selecciona',
                    type: 'CALIFICACION'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOptionContainerFil extends ConsumerWidget {
  final String title;
  final String trailing;
  final String type;
  final bool? search;
  final bool? multi;

  const FilterOptionContainerFil(
      {super.key,
      required this.title,
      required this.trailing,
      required this.type,
      this.search,
      this.multi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FilterOption> listFilters = ref.watch(companiesProvider).filters;

    String? nameFilter;

    nameFilter =
        findFilterOptionByType(listFilters, type, 'name', 'Selecciona');

    return InkWell(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => FilterDetailCompanies(
              title: title, type: type, isSearch: search, isMulti: multi),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(nameFilter ?? '',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: nameFilter == 'Selecciona'
                                ? const Color.fromARGB(255, 170, 170, 170)
                                : Colors.black)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color.fromARGB(255, 175, 174, 174),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

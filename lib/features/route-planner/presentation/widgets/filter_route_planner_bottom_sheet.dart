import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/route-planner/presentation/widgets/filter_detail_route_planner.dart';
import 'package:crm_app/features/shared/widgets/find_filter_option_by_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterBottomRouterPlannerSheet extends ConsumerStatefulWidget {
  @override
  _FilterBottomRouterPlannerSheetState createState() =>
      _FilterBottomRouterPlannerSheetState();
}

class _FilterBottomRouterPlannerSheetState
    extends ConsumerState<FilterBottomRouterPlannerSheet> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight =
        screenHeight * 0.95; // 85% de la altura de la pantalla

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
                    // Acción para aplicar filtros
                    Navigator.pop(context);
                    ref.read(routePlannerProvider.notifier).sendLoadFilter();
                  },
                  child: const Text('Hecho'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final options = [
                  FilterOptionContainerFil(
                      title: 'Horario de trabajo',
                      trailing: 'Selecciona',
                      type: 'HRTR_ID_HORARIO_TRABAJO'),
                  FilterOptionContainerFil(
                      title: 'Muestra sólo en seguimiento',
                      trailing: 'Selecciona',
                      type: 'ESTADO'),
                  FilterOptionContainerFil(
                      title: 'Actividad',
                      trailing: 'Selecciona',
                      type: 'ULTIMAS_VISITAS'),
                  FilterOptionContainerFil(
                      title: 'Tipo',
                      trailing: 'Selecciona',
                      type: 'TIPOCLIENTE'),
                  FilterOptionContainerFil(
                      title: 'Estado',
                      trailing: 'Selecciona',
                      type: 'ESTADO_CRM'),
                  FilterOptionContainerFil(
                      title: 'Calificación',
                      trailing: 'Selecciona',
                      type: 'CALIFICACION'),
                  FilterOptionContainerFil(
                      title: 'Responsable',
                      trailing: 'Selecciona',
                      type: 'ID_USUARIO_RESPONSABLE'),
                  FilterOptionContainerFil(
                      title: 'Código postal',
                      trailing: 'Selecciona',
                      type: 'CODIGO_POSTAL',
                      search: true),
                  FilterOptionContainerFil(
                      title: 'Distrito',
                      trailing: 'Selecciona',
                      type: 'DISTRITO',
                      search: true,
                      multi: true),
                  FilterOptionContainerFil(
                      title: 'RUC',
                      trailing: 'Selecciona',
                      type: 'RUC',
                      search: true),
                  FilterOptionContainerFil(
                      title: 'RUBRO', trailing: 'Selecciona', type: 'ID_RUBRO'),
                  FilterOptionContainerFil(
                      title: 'Razón comercial',
                      trailing: 'Selecciona',
                      type: 'RAZON_COMERCIAL',
                      search: true),
                ];

                return options[index];
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: 12,
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

  FilterOptionContainerFil(
      {required this.title,
      required this.trailing,
      required this.type,
      this.search,
      this.multi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FilterOption> listFilters =
        ref.watch(routePlannerProvider).filters;

    //final String? nameFilter = findFilterOptionIdByType(listFilters, type);
    final String? nameFilter =
        findFilterOptionByType(listFilters, type, 'name', 'Selecciona');

    //options[index].trailing = '';
    return InkWell(
      onTap: ()async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => FilterDetailRoutePlanner(
              title: title, type: type, isSearch: search, isMulti: multi),
        );
        // ref.read(provider)
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
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(nameFilter ?? '',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
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
            )
          ],
        ),
      ),
    );
  }
}

String? findFilterOptionIdByType(List<FilterOption> filters, String type) {
  try {
    return filters.firstWhere((filter) => filter.type == type).name;
  } catch (e) {
    return 'Selecciona';
  }
}

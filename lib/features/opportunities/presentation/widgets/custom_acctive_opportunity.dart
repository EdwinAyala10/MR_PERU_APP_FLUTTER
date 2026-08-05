import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/opportunities/presentation/providers/filter_active_opportunity_provider.dart';
import 'package:crm_app/features/opportunities/presentation/providers/opportunities_provider.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/route-planner/presentation/widgets/filter_detail_route_planner.dart';
import 'package:crm_app/features/shared/widgets/find_filter_option_by_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FilterActivityOpportunity extends ConsumerStatefulWidget {
  const FilterActivityOpportunity({super.key});

  @override
  ConsumerState<FilterActivityOpportunity> createState() =>
      _FilterActivityOpportunityState();
}

class _FilterActivityOpportunityState
    extends ConsumerState<FilterActivityOpportunity> {
  bool _hasProbabilityFilter(RangeValues rangeProb) {
    return rangeProb.start.round() != 0 || rangeProb.end.round() != 100;
  }

  bool _hasValueFilter() {
    return ref.read(startValueProvider) != 0 || ref.read(endValueProvider) != 0;
  }

  bool _hasDateFilter() {
    return ref.read(startDateProvider) != null || ref.read(endDateProvider) != null;
  }

  void _clearProbabilityFilter() {
    ref.read(rangeProbProvider.notifier).state = const RangeValues(0, 100);
  }

  void _clearValueFilter() {
    ref.read(startValueProvider.notifier).state = 0;
    ref.read(endValueProvider.notifier).state = 0;
  }

  void _clearDateFilter() {
    ref.read(startDateProvider.notifier).state = null;
    ref.read(endDateProvider.notifier).state = null;
  }

  void _clearAllFilters() {
    ref.read(routePlannerProvider.notifier).clearDraftFilters();
    resetAllProvidersFilterOP(ref);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight =
        screenHeight * 0.95; // 85% de la altura de la pantalla
    final rangeProb = ref.watch(rangeProbProvider);
    final startDate = ref.watch(startDateProvider);
    final endDate = ref.watch(endDateProvider);
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
                      'Filtros Oportunidades',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: const Text('Limpiar'),
                    ),
                    TextButton(
                      onPressed: () async {
                    // Acción para aplicar fi'ltros
                    ref.read(opportunitiesProvider.notifier).clearOpList();

                    final startP = rangeProb.start.round().toString();
                    final endtP = rangeProb.end.round().toString();

                    Navigator.pop(context);
                    ref.read(routePlannerProvider.notifier).updateFilters();
                    ref
                        .read(opportunitiesProvider.notifier)
                        .loadFiltersOpportunity(
                          isRefresh: true,
                          endDate:
                              formatOpportunityFilterDate(ref.read(endDateProvider)),
                          startDate: formatOpportunityFilterDate(
                              ref.read(startDateProvider)),
                          estadoOP: findFilterByType(
                                      ref.read(routePlannerProvider).filters,
                                      "ID_TIPO_OPORTUNIDAD")
                                  ?.id ??
                              '',
                          endPercents: endtP,
                          startPercent: startP,
                          startValue: (ref.read(startValueProvider) != 0 ||
                                  ref.read(endValueProvider) != 0)
                              ? ref.read(startValueProvider).toInt().toString()
                              : "",
                          endValue: (ref.read(startValueProvider) != 0 ||
                                  ref.read(endValueProvider) != 0)
                              ? ref.read(endValueProvider).toInt().toString()
                              : "",
                          userResponsable:
                              resolveResponsibleFilterValue(ref),
                        );
                      },
                      child: const Text('Hecho'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final options = [
                  const FilterOptionContainerFil(
                    title: 'Estado de oportunidad',
                    trailing: 'Selecciona',
                    type: 'ID_TIPO_OPORTUNIDAD',
                  ),
                  OptionContainFilter(
                    title: 'Probabilidad',
                    trailing: 'Selecciona',
                    type: 'PROBABILIDAD',
                    value: _hasProbabilityFilter(rangeProb)
                        ? '${rangeProb.start.round()}% - ${rangeProb.end.round()}%'
                        : 'Selecciona',
                    onClear:
                        _hasProbabilityFilter(rangeProb) ? _clearProbabilityFilter : null,
                    ontap: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const ProbabilityForm(
                          title: "Probabilidad",
                        ),
                      );
                    },
                  ),
                  OptionContainFilter(
                    title: 'Valor',
                    trailing: 'Selecciona',
                    type: 'VALOR',
                    value: _hasValueFilter()
                        ? "${ref.watch(startValueProvider)} - ${ref.watch(endValueProvider)}"
                        : 'Selecciona',
                    onClear: _hasValueFilter() ? _clearValueFilter : null,
                    ontap: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const ValueForm(
                          title: "Valor",
                        ),
                      );
                    },
                  ),
                  OptionContainFilter(
                    title: 'Fecha prevista  de venta',
                    trailing: 'Selecciona',
                    type: 'FECHA_PREVISTA_VENTA',
                    value: _hasDateFilter()
                        ? "${formatOpportunityFilterDate(startDate)} - ${formatOpportunityFilterDate(endDate)}"
                        : 'Selecciona',
                    onClear: _hasDateFilter() ? _clearDateFilter : null,
                    ontap: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const DateForm(
                          title: "Fecha Prevista",
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: ref.watch(authProvider).user?.isAdmin ?? false,
                    child: const FilterOptionContainerFil(
                      title: 'Responsable',
                      trailing: 'Selecciona',
                      type: 'ID_USUARIO_RESPONSABLE',
                    ),
                  ),
                ];

                return options[index];
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: 5,
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

  const FilterOptionContainerFil({
    super.key,
    required this.title,
    required this.trailing,
    required this.type,
    this.search,
    this.multi,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FilterOption> listFilters =
        ref.watch(routePlannerProvider).filters;

    final String? nameFilter = findFilterOptionByType(
      listFilters,
      type,
      'name',
      'Selecciona',
    );

    return InkWell(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => FilterDetailRoutePlanner(
            title: title,
            type: type,
            isSearch: search,
            isMulti: multi,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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

FilterOption? findFilterByType(List<FilterOption> filters, String type) {
  try {
    return filters.firstWhere((filter) => filter.type == type);
  } catch (e) {
    return null;
  }
}

String resolveResponsibleFilterValue(WidgetRef ref) {
  final user = ref.read(authProvider).user;
  if ((user?.isAdmin ?? false) == false) {
    return user?.code ?? '';
  }

  final routePlannerState = ref.read(routePlannerProvider);
  final selected =
      findFilterByType(routePlannerState.filtersSuccess, 'ID_USUARIO_RESPONSABLE') ??
          findFilterByType(routePlannerState.filters, 'ID_USUARIO_RESPONSABLE');

  return (selected?.id ?? '').trim();
}

class OptionContainFilter extends ConsumerWidget {
  final String title;
  final String trailing;
  final String type;
  final String? value;
  final Function()? ontap;
  final VoidCallback? onClear;

  const OptionContainFilter({
    super.key,
    required this.title,
    required this.trailing,
    required this.type,
    this.value,
    this.ontap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(value ?? '',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: value == 'Selecciona'
                              ? const Color.fromARGB(255, 170, 170, 170)
                              : Colors.black)),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (onClear != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: onClear,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color.fromARGB(255, 140, 140, 140),
                      ),
                    ),
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

class ProbabilityForm extends ConsumerWidget {
  final String title;
  const ProbabilityForm({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight = screenHeight * 0.95;
    final rangeProb = ref.watch(rangeProbProvider);
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
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                /*if(widget.isMulti == true)
                  TextButton(
                    onPressed: () {
                      // Acción para aplicar filtros
                     // Navigator.pop(context);
                    },
                    child: const Text('Hecho'),
                  ),*/
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FILTRAR POR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${rangeProb.start.round()}%'),
                    Text('${rangeProb.end.round()}%'),
                  ],
                ),
                RangeSlider(
                  values: rangeProb,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  labels: RangeLabels(
                    '${rangeProb.start.round()}%',
                    '${rangeProb.end.round()}%',
                  ),
                  onChanged: (RangeValues values) {
                    ref.read(rangeProbProvider.notifier).state = values;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ValueForm extends ConsumerStatefulWidget {
  final String title;
  const ValueForm({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<ValueForm> createState() => _ValueFormState();
}

class _ValueFormState extends ConsumerState<ValueForm> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    final startValue = ref.read(startValueProvider);
    final endValue = ref.read(endValueProvider);
    _startController = TextEditingController(
      text: startValue == 0 ? '' : startValue.toString(),
    );
    _endController = TextEditingController(
      text: endValue == 0 ? '' : endValue.toString(),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
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
                 Expanded(
                   child: Center(
                     child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                /*if(widget.isMulti == true)
                  TextButton(
                    onPressed: () {
                      // Acción para aplicar filtros
                     // Navigator.pop(context);
                    },
                    child: const Text('Hecho'),
                  ),*/
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FILTRAR POR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _startController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Desde",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(startValueProvider.notifier).state =
                        double.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(
                  width: 10,
                  height: 10,
                ),
                TextField(
                  controller: _endController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Hasta",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(endValueProvider.notifier).state =
                        double.tryParse(value) ?? 1000;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DateForm extends ConsumerWidget {
  final String title;
  const DateForm({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight = screenHeight * 0.95;
    final startDate = ref.watch(startDateProvider);
    final endDate = ref.watch(endDateProvider);
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
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                /*if(widget.isMulti == true)
                  TextButton(
                    onPressed: () {
                      // Acción para aplicar filtros
                     // Navigator.pop(context);
                    },
                    child: const Text('Hecho'),
                  ),*/
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DESDE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true, ref),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startDate != null
                                ? DateFormat("dd/MM/yyyy").format(startDate)
                                : "Seleccionar",
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'HASTA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false, ref),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            endDate != null
                                ? DateFormat("dd/MM/yyyy").format(endDate)
                                : "Seleccionar",
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, bool isFrom, WidgetRef ref) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isFrom) {
        ref.read(startDateProvider.notifier).state = picked;
      } else {
        ref.read(endDateProvider.notifier).state = picked;
      }
    }
  }
}

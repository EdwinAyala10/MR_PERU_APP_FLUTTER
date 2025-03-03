import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/opportunities/presentation/providers/filter_active_opportunity_provider.dart';
import 'package:crm_app/features/opportunities/presentation/providers/opportunities_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FilterOpportunityActive extends ConsumerStatefulWidget {
  const FilterOpportunityActive({super.key});

  @override
  ConsumerState<FilterOpportunityActive> createState() =>
      _FilterOpportunityActiveState();
}

class _FilterOpportunityActiveState
    extends ConsumerState<FilterOpportunityActive> {
  final Map<String, String> options = {
    "Lead Abiertos": "01",
    "Contactado": "02",
    "Oferta Enviada": "03",
    "En negociacion": "04",
    "En pausa": "05",
  };

  void toggleOption(String key, bool? value) {
    final currentState = ref.read(selectedCodesProvider.notifier);
    final updatedSet = Set<String>.from(currentState.state);

    if (value == true) {
      updatedSet.add(options[key]!);
    } else {
      updatedSet.remove(options[key]!);
    }
    currentState.state = updatedSet;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCodes =
        ref.watch(selectedCodesProvider); // Observa los códigos seleccionados

    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  GoRouter.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              const Expanded(
                child: Text(
                  "FILTRO DE OPORTUNIDAD",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // GoRouter.of(context).pop();
                  showLoadingMessage(context);
                  await ref
                      .read(opportunitiesProvider.notifier)
                      .loadFiltersOpportunity(
                        isRefresh: true,
                        endDate: ref.read(endDateProvider).toString(),
                        startDate: ref.read(startDateProvider).toString(),
                        status: selectedCodes.join(','),
                        endPercent: ref.read(probendProvider).toString(),
                        startPercent: ref.read(probstartProvider).toString(),
                        startValue: ref.read(startValueProvider).toString(),
                        endValue: ref.read(endValueProvider).toString(),
                      );
                  GoRouter.of(context).pop();
                  GoRouter.of(context).pop();
                },
                child: const Text('Hecho'),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ExpansionTile(
                      title: const Text("ESTADO"),
                      leading: const Icon(Icons.checklist),
                      children: [
                        ...options.entries.map((entry) {
                          return CheckboxListTile(
                            title: Text(entry.key),
                            value: selectedCodes.contains(entry.value),
                            onChanged: (value) =>
                                toggleOption(entry.key, value),
                          );
                        }).toList(),
                      ]),
                  const Divider(
                    height: 0,
                  ),
                  ExpansionTile(
                    title: const Text("PROBABILIDAD"),
                    leading: const Icon(Icons.checklist),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: ref.watch(probstartProvider),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: "${ref.read(probstartProvider).toInt()}%",
                              onChanged: (value) {
                                ref.read(probstartProvider.notifier).state =
                                    value;
                              },
                            ),
                          ),
                          Text("${ref.read(probstartProvider).toInt()}%"),
                          const Text(" - "),
                          Expanded(
                            child: Slider(
                              value: ref.watch(probendProvider),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: "${ref.read(probendProvider).toInt()}%",
                              onChanged: (value) {
                                ref.read(probendProvider.notifier).state =
                                    value;
                              },
                            ),
                          ),
                          Text("${ref.read(probendProvider).toInt()}%"),
                        ],
                      ),
                    ],
                  ),
                  const Divider(
                    height: 0,
                  ),
                  ExpansionTile(
                    title: const Text("FECHA"),
                    leading: const Icon(Icons.checklist),
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Desde",
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(ref.watch(startDateProvider) != null
                                    ? DateFormat("dd/MM/yyyy")
                                        .format(ref.read(startDateProvider)!)
                                    : "Seleccionar"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Hasta",
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(ref.watch(endDateProvider) != null
                                    ? DateFormat("dd/MM/yyyy")
                                        .format(ref.read(endDateProvider)!)
                                    : "Seleccionar"),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  const Divider(
                    height: 0,
                  ),
                  ExpansionTile(
                    title: const Text("VALOR"),
                    leading: const Icon(Icons.checklist),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
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
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectDate(BuildContext context, bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(
        () {
          if (isFrom) {
            ref.read(startDateProvider.notifier).state = picked;
          } else {
            ref.read(endDateProvider.notifier).state = picked;
          }
        },
      );
    }
  }
}

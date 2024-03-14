import 'dart:async';

import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/providers.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';

import 'package:crm_app/features/contacts/presentation/search/search_contacts_active_provider.dart';
import 'package:crm_app/features/contacts/presentation/delegates/search_contact_active_delegate.dart';

import 'package:crm_app/features/companies/presentation/search/search_companies_active_provider.dart';
import 'package:crm_app/features/companies/presentation/delegates/search_company_active_delegate.dart';

import 'package:crm_app/features/opportunities/presentation/search/search_opportunities_active_provider.dart';
import 'package:crm_app/features/opportunities/presentation/delegates/search_opportunity_active_delegate.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class KpiScreen extends ConsumerWidget {
  final String kpiId;

  const KpiScreen({super.key, required this.kpiId});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiState = ref.watch(kpiProvider(kpiId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear objectivo'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: kpiState.isLoading
            ? const FullScreenLoader()
            : _KpiView(kpi: kpiState.kpi!),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (kpiState.kpi == null) return;

            ref
                .read(kpiFormProvider(kpiState.kpi!).notifier)
                .onFormSubmit()
                .then((CreateUpdateKpiResponse value) {
              //if ( !value.response ) return;
              if (value.message != '') {
                showSnackbar(context, value.message);

                if (value.response) {
                  Timer(const Duration(seconds: 3), () {
                    context.push('/kpis');
                  });
                }
              }
            });
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}

class _KpiView extends ConsumerWidget {
  final Kpi kpi;

  const _KpiView({required this.kpi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        _KpiInformation(kpi: kpi),
      ],
    );
  }
}

class _KpiInformation extends ConsumerWidget {
  final Kpi kpi;

  const _KpiInformation({required this.kpi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    List<DropdownOption> optionsAsignacion = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', 'INDIVIDUAL'),
      DropdownOption('02', 'EQUIPO'),
    ];

    List<DropdownOption> optionsCategoria = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', 'VENTAS'),
      DropdownOption('02', 'VISITA'),
    ];

    List<DropdownOption> optionsTipo = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', 'TIPO 1'),
      DropdownOption('02', 'TIPO 2'),
    ];

    List<DropdownOption> optionsPeriodicidad = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', 'MENSUAL'),
    ];

    final kpiForm = ref.watch(kpiFormProvider(kpi));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          const Text(
            'Responsable',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(label: Text(kpiForm.objrNombreUsuarioResponsable ?? ''))
                  ],
                  /*List.generate(
                    tags.length,
                    (index) => Chip(
                      label: Text(tags[index]),
                    ),
                  ),*/
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Asignación',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: kpiForm.objrIdAsignacion,
                      onChanged: (String? newValue) {
                        DropdownOption searchAsignacion = optionsAsignacion
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(kpiFormProvider(kpi).notifier)
                            .onAsignacionChanged(
                                newValue ?? '', searchAsignacion.name);
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      // Mapeo de las opciones a elementos de menú desplegable
                      items: optionsAsignacion.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'DEFINICIÓN DEL OBJETIVO',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Categoria',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: kpiForm.objrIdCategoria,
                      onChanged: (String? newValue) {
                        DropdownOption searchCategoria = optionsCategoria
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(kpiFormProvider(kpi).notifier)
                            .onCategoriaChanged(
                                newValue ?? '', searchCategoria.name);
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      // Mapeo de las opciones a elementos de menú desplegable
                      items: optionsCategoria.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Tipo',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: kpiForm.objrIdTipo,
                      onChanged: (String? newValue) {
                        DropdownOption searchTipo = optionsTipo
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(kpiFormProvider(kpi).notifier)
                            .onTipoChanged(
                                newValue ?? '', searchTipo.name);
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      // Mapeo de las opciones a elementos de menú desplegable
                      items: optionsTipo.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          CustomCompanyField(
            label: 'Nombre de objetivo *',
            initialValue: kpiForm.objrNombre.value,
            onChanged: ref
                .read(kpiFormProvider(kpi).notifier)
                .onNombreChanged,
            errorMessage: kpiForm.objrNombre.errorMessage,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Periodicidad',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: kpiForm.objrIdPeriodicidad,
                      onChanged: (String? newValue) {
                        DropdownOption searchPeriodicidad = optionsPeriodicidad
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(kpiFormProvider(kpi).notifier)
                            .onPeriodicidadChanged(
                                newValue ?? '', searchPeriodicidad.name);
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      // Mapeo de las opciones a elementos de menú desplegable
                      items: optionsPeriodicidad.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: kpiForm.objrObservaciones ?? '',
            onChanged: ref
                .read(kpiFormProvider(kpi).notifier)
                .onObservacionesChanged,
          ),
          const SizedBox(height: 10),
          /*Center(
          child: DropdownButton<String>(
            value: scores.first,
            onChanged: (String? newValue) {
              print('Nuevo valor seleccionado: $newValue');
            },
            items: scores.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),*/

          const SizedBox(height: 70),
        ],
      ),
    );
  }

}


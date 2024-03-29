import 'dart:async';

import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/entities/periodicidad.dart';
import 'package:crm_app/features/kpis/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:crm_app/features/users/presentation/delegates/search_user_delegate.dart';
import 'package:crm_app/features/users/presentation/search/search_users_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KpiScreen extends ConsumerWidget {
  final String kpiId;

  const KpiScreen({super.key, required this.kpiId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiState = ref.watch(kpiProvider(kpiId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear objectivo'),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: kpiState.isLoading
            ? const FullScreenLoader()
            : _KpiView(kpi: kpiState.kpi!),
        floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.save,
          callOnPressed: () {
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
                    context.push('/dashboard');
                  });
                }
              }
            });
        }),
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
      DropdownOption('01', 'INDIVIDUAL'),
      DropdownOption('02', 'EQUIPO'),
    ];

    List<DropdownOption> optionsCategoria = [
      DropdownOption('01', 'CHECK-INS'),
      DropdownOption('02', 'VISITAS'),
      DropdownOption('03', 'NUEVAS EMPRESAS'),
      DropdownOption('04', 'NUEVAS OPORTUNIDADES'),
      DropdownOption('05', 'OPORTUNIDADES GANADAS'),
    ];

    List<DropdownOption> optionsPeriodicidad = [
      DropdownOption('01', 'SEMANAL'),
      DropdownOption('02', 'MENSUAL'),
      DropdownOption('03', 'TRIMESTRAL'),
      DropdownOption('04', 'ANUAL'),
    ];

    List<DropdownOption> optionsTipo = [
      DropdownOption('01', 'VISITA'),
    ];

    final kpiForm = ref.watch(kpiFormProvider(kpi));
    final kpiState = ref.watch(kpiProvider(kpi.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Responsable',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Wrap(
                spacing: 8.0,
                children: [
                  Chip(label: Text(kpiForm.objrNombreUsuarioResponsable ?? ''))
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 16,
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
                      onChanged: kpiForm.id == "new" ? (String? newValue) {
                        DropdownOption searchAsignacion = optionsAsignacion
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(kpiFormProvider(kpi).notifier)
                            .onAsignacionChanged(
                                newValue ?? '', searchAsignacion.name);
                      } : null,
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      items: optionsAsignacion.map((option) {
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
          const Text('Seleccione Usuario(s):'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  kpiForm.arrayuserasignacion!.isNotEmpty
                      ? Wrap(
                          spacing: 6.0,
                          children: kpiForm.arrayuserasignacion != null
                              ? List<Widget>.from(kpiForm.arrayuserasignacion!
                                  .map((item) => Chip(
                                        label: Text(item.name ?? '',
                                            style: const TextStyle(
                                                fontSize:
                                                    12)), // Aquí deberías colocar el texto que deseas mostrar en el chip para cada elemento de la lista
                                        onDeleted: () {
                                          ref
                                              .read(
                                                  kpiFormProvider(kpi).notifier)
                                              .onDeleteUserChanged(item);

                                          // Aquí puedes manejar la eliminación del chip si es necesario
                                        },
                                      )))
                              : [],
                        )
                      : const Text('Seleccione usuario(s)',
                          style: TextStyle(color: Colors.black45)),
                ],
              )),
              ElevatedButton(
                onPressed: kpiForm.id == "new" ? () {
                  if (kpiForm.objrIdAsignacion == '01' &&
                      kpiForm.arrayuserasignacion?.length == 1) {
                    showSnackbar(context, 'Solo debe seleccionar un usuario');
                  } else {
                    _openSearchUsers(context, ref);
                  }
                } : null,
                child: const Row(
                  children: [
                    Icon(Icons.add),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
                      onChanged: kpiForm.id == "new" ? (String? newValue) {
                        DropdownOption searchCategoria = optionsCategoria
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(kpiFormProvider(kpi).notifier)
                            .onCategoriaChanged(
                                newValue ?? '', searchCategoria.name);
                      } : null,
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
          kpiForm.objrIdCategoria == '01'
              ? Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Tipo',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double
                            .infinity, // Ancho específico para el DropdownButton
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey), // Estilo de borde
                            borderRadius: BorderRadius.circular(
                                5.0), // Bordes redondeados
                          ),
                          child: DropdownButton<String>(
                            value: kpiForm.objrIdTipo,
                            onChanged: kpiForm.id == "new" ? (String? newValue) {
                              DropdownOption searchTipo = optionsTipo
                                  .where((option) => option.id == newValue!)
                                  .first;
                              ref
                                  .read(kpiFormProvider(kpi).notifier)
                                  .onTipoChanged(
                                      newValue ?? '', searchTipo.name);
                            } : null,
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
                )
              : Container(),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Nombre de objetivo *',
            initialValue: kpiForm.objrNombre.value,
            onChanged: ref.read(kpiFormProvider(kpi).notifier).onNombreChanged,
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
                      onChanged: kpiForm.id == "new" ? (String? newValue) {
                        DropdownOption searchPeriodicidad = optionsPeriodicidad
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(kpiFormProvider(kpi).notifier)
                            .onPeriodicidadChanged(
                                newValue ?? '', searchPeriodicidad.name);
                      } : null,
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
          const SizedBox(height: 10),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'OBJETIVOS ALCANZAR',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(10), // Radio de borde del contenedor
              border: Border.all(
                color: Colors.black45, // Color del borde del contenedor
                width: 1, // Ancho del borde del contenedor
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCompanyField(
                  label: 'Objetivo individual a alcanzar',
                  initialValue: kpiForm.objrCantidad,
                  enabled: !kpiForm.objrValorDifMes,
                  onChanged:
                      ref.read(kpiFormProvider(kpi).notifier).onCantidadChanged,
                ),
                const SizedBox(
                  height: 10,
                ),
                kpiForm.objrIdPeriodicidad == '02'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Valor diferente cada mes',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Switch(
                            value: kpiForm.objrValorDifMes,
                            onChanged: (bool bol) {
                              ref
                                  .read(kpiFormProvider(kpi).notifier)
                                  .onCheckDifMesChanged(bol);
                            },
                          ),
                        ],
                      )
                    : const SizedBox(),
                kpiForm.objrIdPeriodicidad == '02'
                    ? const SizedBox(
                        height: 10,
                      )
                    : const SizedBox(),
                if (kpiForm.objrIdPeriodicidad == '02' &&
                    kpiForm.objrValorDifMes)
                  for (var periodicidad in kpiForm.peobIdPeriodicidad ?? [])
                    ItemMes(periodicidad: periodicidad, ref: ref, kpi: kpi),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: kpiForm.objrObservaciones ?? '',
            onChanged: kpiForm.id == "new" ?
                ref.read(kpiFormProvider(kpi).notifier).onObservacionesChanged : null,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _openSearchUsers(BuildContext context, WidgetRef ref) async {
    final searchedUsers = ref.read(searchedUsersProvider);
    final searchQuery = ref.read(searchQueryUsersProvider);

    showSearch<UserMaster?>(
            query: searchQuery,
            context: context,
            delegate: SearchUserDelegate(
                initialUsers: searchedUsers,
                searchUsers: ref
                    .read(searchedUsersProvider.notifier)
                    .searchUsersByQuery))
        .then((user) {
      if (user == null) return;

      ref.read(kpiFormProvider(kpi).notifier).onUsuarioChanged(user);
    });
  }
}

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class ItemMes extends StatelessWidget {
  WidgetRef ref;
  Periodicidad periodicidad;
  Kpi kpi;
  ItemMes({super.key, required this.periodicidad, required this.ref, required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(periodicidad.periNombre ??
                ''), // Suponiendo que cada elemento tiene un atributo 'mes'
            const Spacer(),
            SizedBox(
              width: 200,
              child: TextFormField(
                initialValue: periodicidad.peobCantidad,
                onChanged: (value) {
                  ref
                      .read(kpiFormProvider(kpi).notifier)
                      .onCantidadPorMesChanged(value, periodicidad);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        )
      ],
    );
  }
}

import 'dart:async';

import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';

import 'package:crm_app/features/contacts/presentation/search/search_contacts_active_provider.dart';
import 'package:crm_app/features/contacts/presentation/delegates/search_contact_active_delegate.dart';

import 'package:crm_app/features/companies/presentation/search/search_companies_active_provider.dart';
import 'package:crm_app/features/companies/presentation/delegates/search_company_active_delegate.dart';

import 'package:crm_app/features/opportunities/presentation/search/search_opportunities_active_provider.dart';
import 'package:crm_app/features/opportunities/presentation/delegates/search_opportunity_active_delegate.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/select_custom_form.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends ConsumerWidget {
  final String activityId;

  const ActivityScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityProvider(activityId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Actividad'),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: activityState.isLoading
            ? const FullScreenLoader()
            : _ActivityView(activity: activityState.activity!),
        floatingActionButton: FloatingActionButtonCustom(
            iconData: Icons.save,
            callOnPressed: () {
              if (activityState.activity == null) return;

              ref
                  .read(activityFormProvider(activityState.activity!).notifier)
                  .onFormSubmit()
                  .then((CreateUpdateActivityResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);

                  if (value.response) {
                    Timer(const Duration(seconds: 3), () {
                      context.push('/activities');
                    });
                  }
                }
              });
            }),
      ),
    );
  }
}

class _ActivityView extends ConsumerWidget {
  final Activity activity;

  const _ActivityView({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        _ActivityInformation(activity: activity),
      ],
    );
  }
}

class _ActivityInformation extends ConsumerWidget {
  final Activity activity;

  const _ActivityInformation({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var scores = ['A', 'B', 'C', 'D'];

    List<String> tags = ['Aldo Mori'];

    List<DropdownOption> optionsTipoGestion = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', 'Comentario'),
      DropdownOption('02', 'Llamada Telefónica'),
      DropdownOption('03', 'Reunión'),
      DropdownOption('04', 'Visita'),
    ];

    final activityForm = ref.watch(activityFormProvider(activity));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SelectCustomForm(
            label: 'Tipo de gestión *',
            value: activityForm.actiIdTipoGestion.value,
            callbackChange: (String? newValue) {
              DropdownOption searchTipoGestion = optionsTipoGestion
                  .where((option) => option.id == newValue!)
                  .first;
              ref
                  .read(activityFormProvider(activity).notifier)
                  .onTipoGestionChanged(newValue ?? '', searchTipoGestion.name);
            },
            items: optionsTipoGestion,
            errorMessage: activityForm.actiIdTipoGestion.errorMessage,
          ),
          const SizedBox(height: 10),
          const Text(
            'Fecha',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Center(
            child: GestureDetector(
              onTap: () => _selectDate(context, ref),
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
                      DateFormat('dd-MM-yyyy').format(
                          activityForm.actiFechaActividad ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Hora',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _selectTime(context, ref),
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
                    //TimeOfDay.now().format(context),
                    DateFormat('hh:mm a').format(DateFormat('HH:mm:ss')
                        .parse(activityForm.actiHoraActividad)),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.access_time),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'DATOS DE LA GESTIÓN',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Empresa *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchCompanies(context, ref, activityForm.actiIdUsuarioRegistro);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            activityForm.actiRuc.value == ''
                                ? 'Seleccione empresa'
                                : activityForm.actiRazon,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchCompanies(context, ref, activityForm.actiIdUsuarioRegistro);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          activityForm.actiRuc.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    activityForm.actiRuc.errorMessage ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oportunidad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    if (activityForm.actiRuc.value == null) {
                      showSnackbar(context, 'Seleccione una empresa');
                      return;
                    }
                    _openSearchOportunities(context, ref, activityForm.actiRuc.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            activityForm.actiIdOportunidad.value == ''
                                ? 'Seleccione Oportunidad'
                                : activityForm.actiNombreOportunidad,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            if (activityForm.actiRuc.value == null) {
                              showSnackbar(context, 'Seleccione una empresa');
                              return;
                            }
                            _openSearchOportunities(context, ref, activityForm.actiRuc.value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          activityForm.actiIdOportunidad.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    activityForm.actiIdOportunidad.errorMessage ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 15),
          const Text('Contactos *'),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  activityForm.actividadesContacto!.isNotEmpty
                      ? Wrap(
                          spacing: 6.0,
                          children: activityForm.actividadesContacto != null
                              ? List<Widget>.from(activityForm
                                  .actividadesContacto!
                                  .map((item) => Chip(
                                        label: Text(item.contactoDesc ?? '',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        onDeleted: () {
                                          ref
                                              .read(
                                                  activityFormProvider(activity)
                                                      .notifier)
                                              .onDeleteContactoChanged(item);
                                        },
                                      )))
                              : [],
                        )
                      : const Text('Seleccione contacto(s)',
                          style: TextStyle(color: Colors.black45)),
                ],
              )),
              ElevatedButton(
                onPressed: () {
                  _openSearchContacts(context, ref);
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                  ],
                ),
              ),
            ],
          ),
          activityForm.actividadesContacto?.length == 0
              ? const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'Es requerido, seleccione contacto(s)',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox(),

          /*const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contacto *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchContacts(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            activityForm.actiIdContacto.value == ''
                                ? 'Seleccione Contacto'
                                : activityForm.actiNombreContacto,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchContacts(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),*/
          /*activityForm.actiIdContacto.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    activityForm.actiIdContacto.errorMessage ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox(),*/
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
                    Chip(label: Text(activityForm.actiNombreResponsable))
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
          const SizedBox(height: 10),
          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: activityForm.actiComentario,
            onChanged: ref
                .read(activityFormProvider(activity).notifier)
                .onComentarioChanged,
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

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    //print(picked);

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      ref.read(activityFormProvider(activity).notifier).onFechaChanged(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, WidgetRef ref) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      String formattedTime = picked.toString().substring(10, 15) + ':00';
      ref
          .read(activityFormProvider(activity).notifier)
          .onHoraChanged(formattedTime);
    }
  }

  void _openSearchCompanies(BuildContext context, WidgetRef ref, String dni) async {
    final searchedCompanies = ref.read(searchedCompaniesProvider);
    final searchQuery = ref.read(searchQueryCompaniesProvider);

    showSearch<Company?>(
            query: searchQuery,
            context: context,
            delegate: SearchCompanyDelegate(
                dni: dni,
                initialCompanies: searchedCompanies,
                searchCompanies: ref
                    .read(searchedCompaniesProvider.notifier)
                    .searchCompaniesByQuery))
        .then((company) {
      if (company == null) return;

      ref
          .read(activityFormProvider(activity).notifier)
          .onRucChanged(company.ruc, company.razon);
    });
  }

  void _openSearchOportunities(BuildContext context, WidgetRef ref, String ruc) async {
    final searchedOpportunities = ref.read(searchedOpportunitiesProvider);
    final searchQuery = ref.read(searchQueryOpportunitiesProvider);

    showSearch<Opportunity?>(
            query: searchQuery,
            context: context,
            delegate: SearchOpportunityDelegate(
              ruc: ruc,
              initialOpportunities: searchedOpportunities,
              searchOpportunities: ref
                  .read(searchedOpportunitiesProvider.notifier)
                  .searchOpportunitiesByQuery))
        .then((opportunity) {
      if (opportunity == null) return;

      ref
          .read(activityFormProvider(activity).notifier)
          .onOportunidadChanged(opportunity.id, opportunity.oprtNombre);
    });
  }

  void _openSearchContacts(BuildContext context, WidgetRef ref) async {
    final searchedContacts = ref.read(searchedContactsProvider);
    final searchQuery = ref.read(searchQueryContactsProvider);

    showSearch<Contact?>(
            query: searchQuery,
            context: context,
            delegate: SearchContactDelegate(
                initialContacts: searchedContacts,
                searchContacts: ref
                    .read(searchedContactsProvider.notifier)
                    .searchContactsByQuery))
        .then((contact) {
      if (contact == null) return;

      ref
          .read(activityFormProvider(activity).notifier)
          .onContactoChanged(contact);
    });
  }
}

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

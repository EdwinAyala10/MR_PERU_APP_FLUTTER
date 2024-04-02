import 'dart:async';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/delegates/search_company_active_delegate.dart';
import 'package:crm_app/features/companies/presentation/search/search_companies_active_provider.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/select_custom_form.dart';
import 'package:crm_app/features/shared/widgets/title_section_form.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:crm_app/features/users/presentation/delegates/search_user_delegate.dart';
import 'package:crm_app/features/users/presentation/search/search_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OpportunityScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityScreen({super.key, required this.opportunityId});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityState = ref.watch(opportunityProvider(opportunityId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Oportunidad'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: opportunityState.isLoading
            ? const FullScreenLoader()
            : _OpportunityView(opportunity: opportunityState.opportunity!),
        floatingActionButton: FloatingActionButtonCustom(
            iconData: Icons.save,
            callOnPressed: () {
              if (opportunityState.opportunity == null) return;

              ref
                  .read(opportunityFormProvider(opportunityState.opportunity!)
                      .notifier)
                  .onFormSubmit()
                  .then((CreateUpdateOpportunityResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);

                  if (value.response) {
                    //Timer(const Duration(seconds: 3), () {
                      context.push('/opportunities');
                    //});
                  }
                }
              });
            }),
      ),
    );
  }
}

class _OpportunityView extends ConsumerWidget {
  final Opportunity opportunity;

  const _OpportunityView({required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        _OpportunityInformation(opportunity: opportunity),
      ],
    );
  }
}

class _OpportunityInformation extends ConsumerWidget {
  final Opportunity opportunity;

  const _OpportunityInformation({required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> tags = ['Responsable 1', 'Responsable 2', 'Responsable 3'];

    List<DropdownOption> optionsEstado = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', '1. Contactado'),
      DropdownOption('02', '2. Primera visista'),
      DropdownOption('03', '3. Oferta enviada'),
      DropdownOption('04', '4. Esperando pedido'),
    ];

    List<DropdownOption> optionsMoneda = [
      DropdownOption('01', 'USD'),
    ];

    final opportunityForm = ref.watch(opportunityFormProvider(opportunity));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCompanyField(
            isTopField: true,
            label: 'Nombre de la oportunidad *',
            initialValue: opportunityForm.oprtNombre.value,
            onChanged: ref
                .read(opportunityFormProvider(opportunity).notifier)
                .onNameChanged,
            errorMessage: opportunityForm.oprtNombre.errorMessage,
          ),
          TitleSectionForm(title: 'DATOS DE OPORTUNIDAD'),
          SelectCustomForm(
            label: 'Estado',
            value: opportunityForm.oprtIdEstadoOportunidad,
            callbackChange: (String? newValue) {
              ref
                  .read(opportunityFormProvider(opportunity).notifier)
                  .onIdEstadoChanged(newValue!);
            },
            items: optionsEstado,
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Probalidad: ${double.parse(opportunityForm.oprtProbabilidad ?? '0').round()}%',
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10.0),
                Slider(
                  value: double.parse(opportunityForm.oprtProbabilidad),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label:
                      '${double.parse(opportunityForm.oprtProbabilidad).round()}%',
                  onChanged: (double value) {
                    ref
                        .read(opportunityFormProvider(opportunity).notifier)
                        .onProbabilidadChanged(value.toString());
                  },
                ),
              ],
            ),
          ),
          SelectCustomForm(
            label: 'Moneda',
            value: opportunityForm.oprtIdValor,
            callbackChange: (String? newValue) {
              DropdownOption searchEstado =
                  optionsEstado.where((option) => option.id == newValue!).first;

              ref
                  .read(opportunityFormProvider(opportunity).notifier)
                  .onIdValorChanged(newValue!);
              ref
                  .read(opportunityFormProvider(opportunity).notifier)
                  .onValorChanged(searchEstado.name);
            },
            items: optionsMoneda,
          ),
          const SizedBox(height: 10),
      
          CustomCompanyField(
            label: 'Importe Total',
            initialValue: opportunityForm.optrValor.toString(),
            onChanged: ref
                .read(opportunityFormProvider(opportunity).notifier)
                .onImporteChanged,
          ),
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
                          opportunityForm.oprtFechaPrevistaVenta ??
                              DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Empresa principal:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearch(context, ref, 'ruc', opportunityForm.oprtIdUsuarioRegistro);
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
                            opportunityForm.oprtRuc == ''
                                ? 'Seleccione empresa'
                                : opportunityForm.oprtRazon,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearch(context, ref, 'ruc', opportunityForm.oprtIdUsuarioRegistro);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Intermediario:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearch(context, ref, 'intermediario1', opportunityForm.oprtIdUsuarioRegistro);
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
                            opportunityForm.oprtRucIntermediario01 == ''
                                ? 'Seleccione intermediario'
                                : opportunityForm.oprtRazonIntermediario01,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearch(context, ref, 'intermediario1', opportunityForm.oprtIdUsuarioRegistro);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text('Responsable *'),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  opportunityForm.arrayresponsables!.isNotEmpty
                      ? Wrap(
                          spacing: 6.0,
                          children: opportunityForm.arrayresponsables != null
                              ? List<Widget>.from(opportunityForm
                                  .arrayresponsables!
                                  .map((item) => Chip(
                                        label: Text(item.userreportName ?? '',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        onDeleted: () {
                                          ref
                                              .read(opportunityFormProvider(
                                                      opportunity)
                                                  .notifier)
                                              .onDeleteUserChanged(item);
                                        },
                                      )))
                              : [],
                        )
                      : const Text('Seleccione usuario(s)',
                          style: TextStyle(color: Colors.black45)),
                ],
              )),
              ElevatedButton(
                onPressed: () {
                  _openSearchUsers(context, ref);
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: opportunityForm.oprtComentario,
            onChanged: ref
                .read(opportunityFormProvider(opportunity).notifier)
                .onComentarioChanged,
          ),

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

          const SizedBox(height: 90),
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
      ref
          .read(opportunityFormProvider(opportunity).notifier)
          .onFechaChanged(picked);
    }
  }

  void _openSearch(BuildContext context, WidgetRef ref, String type, String dni) async {
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

      if (type == 'ruc') {
        print('ES RUC');
        ref
            .read(opportunityFormProvider(opportunity).notifier)
            .onRucChanged(company.ruc, company.razon);
      }

      if (type == 'intermediario1') {
        print('ES INTERMEDIARIO 1');
        ref
            .read(opportunityFormProvider(opportunity).notifier)
            .onRucIntermediario01Changed(company.ruc, company.razon);
      }
    });
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

      ref
          .read(opportunityFormProvider(opportunity).notifier)
          .onUsuarioChanged(user);
    });
  }
}

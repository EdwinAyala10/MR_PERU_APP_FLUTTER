import 'dart:async';

import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/companies/presentation/delegates/search_company_local_active_delegate.dart';
import 'package:crm_app/features/companies/presentation/providers/company_provider.dart';
import 'package:crm_app/features/companies/presentation/search/search_company_locales_active_provider.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';

import '../../../companies/domain/domain.dart';
import '../../../companies/presentation/delegates/search_company_active_delegate.dart';
import '../../../companies/presentation/search/search_companies_active_provider.dart';
import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../../../resource-detail/presentation/providers/resource_details_provider.dart';
import '../../../shared/domain/entities/dropdown_option.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';
import '../../../shared/widgets/title_section_form.dart';
import '../../../users/domain/domain.dart';
import '../../../users/presentation/delegates/search_user_delegate.dart';
import '../../../users/presentation/search/search_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OpportunityScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityState = ref.watch(opportunityProvider(opportunityId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${ opportunityState.opportunity!.id == 'new' ? 'Crear': 'Editar' } oportunidad'
          , style: const TextStyle(
            fontWeight: FontWeight.w500
          )),
          //title: const Text('Crear Oportunidad', style: TextStyle(fontWeight: FontWeight.w500)),
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

              showLoadingMessage(context);

              ref
                  .read(opportunityFormProvider(opportunityState.opportunity!)
                      .notifier)
                  .onFormSubmit()
                  .then((CreateUpdateOpportunityResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);

                  if (value.response) {
                    ref.read(opportunityProvider(opportunityId).notifier).loadOpportunity();
                    ref.read(companyProvider(value.id!).notifier).loadSecundaryOpportunities();

                    ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
                    //Timer(const Duration(seconds: 3), () {
                      //context.push('/opportunities');
                      context.pop();
                    //});
                  }
                }
                Navigator.pop(context);

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
        _OpportunityInformationv2(opportunity: opportunity),
      ],
    );
  }
}

class _OpportunityInformationv2 extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const _OpportunityInformationv2({required this.opportunity});

  @override
  _OpportunityInformationv2State createState() => _OpportunityInformationv2State();
}

class _OpportunityInformationv2State extends ConsumerState<_OpportunityInformationv2> {
  List<DropdownOption> optionsEstado = [
    DropdownOption(id: '', name: 'Cargando...')
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await ref.read(resourceDetailsProvider.notifier).loadCatalogById('05').then((value) => {
        setState(() {
          optionsEstado = value;
        })
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    List<DropdownOption> optionsMoneda = [
      DropdownOption(id: '01', name: 'USB'),
    ];

    User authUser = ref.watch(authProvider).user!;
    bool isAdmin = authUser.isAdmin;

    final opportunityForm = ref.watch(opportunityFormProvider(widget.opportunity));

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
                .read(opportunityFormProvider(widget.opportunity).notifier)
                .onNameChanged,
            errorMessage: opportunityForm.oprtNombre.errorMessage,
          ),
          TitleSectionForm(title: 'DATOS DE OPORTUNIDAD'),
          optionsEstado.length > 1 ? SelectCustomForm(
            label: 'Estado',
            value: opportunityForm.oprtIdEstadoOportunidad.value,
            callbackChange: (String? newValue) {
              ref
                  .read(opportunityFormProvider(widget.opportunity).notifier)
                  .onIdEstadoChanged(newValue!);
            },
            items: optionsEstado,
            errorMessage: opportunityForm.oprtIdEstadoOportunidad.errorMessage,
          ): PlaceholderInput(text: 'Cargando Estado...'),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Probabilidad: ${double.parse(opportunityForm.oprtProbabilidad).round()}%',
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
                        .read(opportunityFormProvider(widget.opportunity).notifier)
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
                  .read(opportunityFormProvider(widget.opportunity).notifier)
                  .onIdValorChanged(newValue!);
              ref
                  .read(opportunityFormProvider(widget.opportunity).notifier)
                  .onValorChanged(searchEstado.name);
            },
            items: optionsMoneda,
          ),
          const SizedBox(height: 10),
      
          CustomCompanyField(
            label: 'Importe Total',
            keyboardType: TextInputType.number,
            initialValue: opportunityForm.optrValor.toString(),
            onChanged: ref
                .read(opportunityFormProvider(widget.opportunity).notifier)
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
                 Text(
                  'Empresa principal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: opportunityForm.oprtRuc.errorMessage != null ? Colors.red : Colors.grey,
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
                        color: opportunityForm.oprtRuc.errorMessage != null ? Colors.red : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opportunityForm.oprtRuc.value == ''
                                ? 'Seleccione empresa'
                                : opportunityForm.oprtRazon,
                            style: TextStyle(
                              fontSize: 16,
                              color: opportunityForm.oprtRuc.errorMessage != null ? Colors.red : Colors.black
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
          opportunityForm.oprtRuc.errorMessage != null
          ? Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                opportunityForm.oprtRuc.errorMessage ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            )
          : const SizedBox(),


          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        opportunityForm.oprtLocalCodigo.errorMessage != null
                            ? Colors.red[400]
                            : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    
                    if (opportunityForm.oprtRuc.value == "") {
                        showSnackbar(context, 'Debe seleccionar una empresa');
                        return;
                    }

                    _openSearchCompanyLocales(
                        context, ref, opportunityForm.oprtRuc.value);

                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              opportunityForm.oprtLocalCodigo.errorMessage !=
                                      null
                                  ? Colors.red
                                  : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opportunityForm.oprtLocalCodigo.value == ''
                                ? 'Seleccione local'
                                : opportunityForm.oprtLocalNombre ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                color: opportunityForm
                                            .oprtLocalCodigo.errorMessage !=
                                        null
                                    ? Colors.red
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            
                            if (opportunityForm.oprtRuc.value == "") {
                                showSnackbar(context, 'Debe seleccionar una empresa');
                                return;
                            }

                            _openSearchCompanyLocales(
                                context, ref, opportunityForm.oprtRuc.value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (opportunityForm.oprtLocalCodigo.errorMessage != null)
            Text(
              opportunityForm.oprtLocalCodigo.errorMessage ?? 'Requerido',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 13
              ),
            ),
          const SizedBox(height: 10),

          /*const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Intermediario',
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
                        color: opportunityForm.oprtRucIntermediario01.errorMessage != null ? Colors.red : Colors.grey
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opportunityForm.oprtRucIntermediario01.value == ''
                                ? 'Seleccione intermediario'
                                : opportunityForm.oprtRazonIntermediario01,
                            style: TextStyle(
                              fontSize: 16,
                              color: opportunityForm.oprtRucIntermediario01.errorMessage != null ? Colors.red : Colors.black
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
          opportunityForm.oprtRucIntermediario01.errorMessage != null
          ? Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                opportunityForm.oprtRucIntermediario01.errorMessage ?? '',
                style: const TextStyle(color: Colors.red),
              ),
            )
          : const SizedBox(),*/
          const SizedBox(height: 15),
          const Text('Responsable', style: TextStyle(
            fontWeight: FontWeight.w500
          ),),
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
                                        onDeleted: !isAdmin ? null 
                                          : item.cresIdUsuarioResponsable != authUser.code
                                         ?  () {
                                          ref
                                              .read(opportunityFormProvider(
                                                      widget.opportunity)
                                                  .notifier)
                                              .onDeleteUserChanged(item);
                                        } : null,
                                      )))
                              : [],
                        )
                      : const Text('Seleccione usuario(s)',
                          style: TextStyle(color: Colors.black45)),
                ],
              )),
              ElevatedButton(
                onPressed: isAdmin ? () {
                  _openSearchUsers(context, ref);
                } : null,
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
                .read(opportunityFormProvider(widget.opportunity).notifier)
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
          .read(opportunityFormProvider(widget.opportunity).notifier)
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
                  .searchCompaniesByQuery,
              resetSearchQuery: () {
                  ref.read(searchQueryCompaniesProvider.notifier).update((state) => '');
              },
          ))
        .then((company) {
      if (company == null) return;

      if (type == 'ruc') {
        ref
            .read(opportunityFormProvider(widget.opportunity).notifier)
            .onRucChanged(company.ruc, company.razon);
      }

      /*if (type == 'intermediario1') {
        ref
            .read(opportunityFormProvider(widget.opportunity).notifier)
            .onRucIntermediario01Changed(company.ruc, company.razon);
      }*/
    });
  }

  void _openSearchUsers(BuildContext context, WidgetRef ref) async {
    final searchedUsers = ref.read(searchedUsersProvider);
    final searchQuery = ref.read(searchQueryUsersProvider);
    final user = ref.watch(authProvider).user;

    final swIsCreate = widget.opportunity.id == 'new';

    showSearch<UserMaster?>(
            query: searchQuery,
            context: context,
            delegate: SearchUserDelegate(
                initialUsers: searchedUsers,
                //userCurrent: user!,
                //idItemDelete: user!.code,
                idItemDelete: swIsCreate ? user!.code : null,
                searchUsers: ref
                    .read(searchedUsersProvider.notifier)
                    .searchUsersByQuery,
                resetSearchQuery: () {
                  ref.read(searchQueryUsersProvider.notifier).update((state) => '');
                },
            ))
        .then((user) {
      if (user == null) return;

      ref
          .read(opportunityFormProvider(widget.opportunity).notifier)
          .onUsuarioChanged(user);
    });
  }

  void _openSearchCompanyLocales(
      BuildContext context, WidgetRef ref, String ruc) async {
    final searchedCompanyLocales = ref.read(searchedCompanyLocalesProvider);
    final searchQuery = ref.read(searchQueryCompanyLocalesProvider);

    showSearch<CompanyLocal?>(
            query: searchQuery,
            context: context,
            delegate: SearchCompanyLocalDelegate(
                ruc: ruc,
                initialCompanyLocales: searchedCompanyLocales,
                searchCompanyLocales: ref
                    .read(searchedCompanyLocalesProvider.notifier)
                    .searchCompanyLocalesByQuery,
                resetSearchQuery: () {
                    ref.read(searchQueryCompanyLocalesProvider.notifier).update((state) => '');
                },
            ))
        .then((companyLocal) {
      if (companyLocal == null) return;

      ref
          .read(opportunityFormProvider(widget.opportunity).notifier)
          .onLocalChanged(companyLocal.id,
              '${companyLocal.localNombre} ${companyLocal.localDireccion}');

    });
  }
}

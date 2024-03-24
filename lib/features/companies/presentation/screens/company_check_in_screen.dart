import 'dart:async';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/delegates/search_contact_active_delegate.dart';
import 'package:crm_app/features/contacts/presentation/search/search_contacts_active_provider.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/delegates/search_opportunity_active_delegate.dart';
import 'package:crm_app/features/opportunities/presentation/search/search_opportunities_active_provider.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyCheckInScreen extends ConsumerWidget {
  final String id;

  const CompanyCheckInScreen({super.key, required this.id});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyCheckInState = ref.watch(companyCheckInProvider(id));


    List<String> ids = id.split("*");
    String idCheck = ids[0];
    String ruc = ids[1];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              'Crear ${companyCheckInState.id == '01' ? 'Check-In' : 'Check-out'}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: companyCheckInState.isLoading
            ? const FullScreenLoader()
            : _CompanyCheckInView(
                companyCheckIn: companyCheckInState.companyCheckIn!),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (companyCheckInState.companyCheckIn == null) return;

            ref
                .read(companyCheckInFormProvider(
                        companyCheckInState.companyCheckIn!)
                    .notifier)
                .onFormSubmit()
                .then((CreateUpdateCompanyCheckInResponse value) {
              //if ( !value.response ) return;
              if (value.message != '') {
                showSnackbar(context, value.message);
                if (value.response) {
                  Timer(const Duration(seconds: 3), () {
                    context.push('/company_detail/${ruc}');
                    //context.push('/company/${company.ruc}');
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

class _CompanyCheckInView extends ConsumerWidget {
  final CompanyCheckIn companyCheckIn;

  const _CompanyCheckInView({required this.companyCheckIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        SizedBox(height: 10),
        _CompanyCheckInInformation(companyCheckIn: companyCheckIn),
      ],
    );
  }
}

class _CompanyCheckInInformation extends ConsumerWidget {
  final CompanyCheckIn companyCheckIn;

  const _CompanyCheckInInformation({required this.companyCheckIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyCheckInForm =
        ref.watch(companyCheckInFormProvider(companyCheckIn));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Empresa',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(label: Text(companyCheckInForm.cchkRazon ?? ''))
                  ],
                ),
              ),
            ],
          ),
          if (companyCheckInForm.cchkRuc.errorMessage != null)
            Text(
              companyCheckInForm.cchkRuc.errorMessage ?? 'Requerido',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oportunidad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: companyCheckInForm.cchkIdOportunidad.errorMessage !=
                            null
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchOportunities(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: companyCheckInForm
                                      .cchkIdOportunidad.errorMessage !=
                                  null
                              ? Theme.of(context).colorScheme.error
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            companyCheckInForm.cchkIdOportunidad.value == ''
                                ? 'Seleccione oportunidad'
                                : companyCheckInForm.cchkNombreOportunidad ??
                                    '',
                            //_selectedCompany.isEmpty ? 'Seleccione una empresa' : _selectedCompany,
                            style: TextStyle(
                                fontSize: 16,
                                color: companyCheckInForm
                                            .cchkIdOportunidad.errorMessage !=
                                        null
                                    ? Theme.of(context).colorScheme.error
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchOportunities(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (companyCheckInForm.cchkIdOportunidad.errorMessage != null)
            Text(
              companyCheckInForm.cchkIdOportunidad.errorMessage ?? 'Requerido',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacto *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        companyCheckInForm.cchkIdContacto.errorMessage != null
                            ? Theme.of(context).colorScheme.error
                            : null,
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
                          color: companyCheckInForm
                                      .cchkIdOportunidad.errorMessage !=
                                  null
                              ? Theme.of(context).colorScheme.error
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            companyCheckInForm.cchkIdContacto.value == ''
                                ? 'Seleccione contacto'
                                : companyCheckInForm.cchkNombreContacto ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                color: companyCheckInForm
                                            .cchkIdContacto.errorMessage !=
                                        null
                                    ? Theme.of(context).colorScheme.error
                                    : null),
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
          ),
          companyCheckInForm.cchkIdContacto.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    companyCheckInForm.cchkIdContacto.errorMessage ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: companyCheckInForm.cchkIdComentario ?? '',
            onChanged: ref
                .read(companyCheckInFormProvider(companyCheckIn).notifier)
                .onComentarioChanged,
          ),
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
                    Chip(
                        label: Text(
                            companyCheckInForm.cchkNombreUsuarioResponsable ??
                                ''))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomCompanyField(
            label: 'Dirección',
            initialValue: companyCheckInForm.cchkDireccionMapa ?? '',
            onChanged: ref
                .read(companyCheckInFormProvider(companyCheckIn).notifier)
                .onDireccionChanged,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /*void _openSearch(BuildContext context, WidgetRef ref) async {
    final searchedCompanies = ref.read(searchedCompaniesProvider);
    final searchQuery = ref.read(searchQueryCompaniesProvider);

    showSearch<Company?>(
            query: searchQuery,
            context: context,
            delegate: SearchCompanyDelegate(
                initialCompanies: searchedCompanies,
                searchCompanies: ref
                    .read(searchedCompaniesProvider.notifier)
                    .searchCompaniesByQuery))
        .then((company) {
      if (company == null) return;

      ref.read(companyCheckInFormProvider(companyCheckIn).notifier).onRucChanged(company.ruc);
      ref.read(companyCheckInFormProvider(companyCheckIn).notifier).onRazonChanged(company.razon);

    });
  }*/

  void _openSearchOportunities(BuildContext context, WidgetRef ref) async {
    final searchedOpportunities = ref.read(searchedOpportunitiesProvider);
    final searchQuery = ref.read(searchQueryOpportunitiesProvider);

    showSearch<Opportunity?>(
            query: searchQuery,
            context: context,
            delegate: SearchOpportunityDelegate(
                initialOpportunities: searchedOpportunities,
                searchOpportunities: ref
                    .read(searchedOpportunitiesProvider.notifier)
                    .searchOpportunitiesByQuery))
        .then((opportunity) {
      if (opportunity == null) return;

      ref
          .read(companyCheckInFormProvider(companyCheckIn).notifier)
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
          .read(companyCheckInFormProvider(companyCheckIn).notifier)
          .onContactoChanged(contact.id, contact.contactoDesc);
    });
  }
}

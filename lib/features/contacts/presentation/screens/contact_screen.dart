import 'dart:async';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/delegates/search_company_active_delegate.dart';
import 'package:crm_app/features/companies/presentation/search/search_companies_active_provider.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/select_custom_form.dart';
import 'package:crm_app/features/shared/widgets/title_section_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ContactScreen extends ConsumerWidget {
  final String contactId;

  const ContactScreen({super.key, required this.contactId});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('CONTAC ID [CONTACT_SCREEN]: ${contactId}');
    final contactState = ref.watch(contactProvider(contactId));
    print('CONTAC ID STATE [CONTACT_SCREEN]: ${contactState.id}');
    print('CONTAC ID STATE CONTACT [CONTACT_SCREEN]: ${contactState.contact?.id}');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Contacto'),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: contactState.isLoading
            ? const FullScreenLoader()
            : _ContactView(contact: contactState.contact!),
        floatingActionButton: FloatingActionButtonCustom(
            callOnPressed: () {
              if (contactState.contact == null) return;

              ref
                  .read(contactFormProvider(contactState.contact!).notifier)
                  .onFormSubmit()
                  .then((CreateUpdateContactResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);

                  if (value.response) {
                    Timer(const Duration(seconds: 3), () {
                      context.push('/contacts');
                    });
                  }
                }
              });
            },
            iconData: Icons.save),
      ),
    );
  }
}

class _ContactView extends ConsumerWidget {
  final Contact contact;

  const _ContactView({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        _ContactInformation(contact: contact),
      ],
    );
  }
}

class _ContactInformation extends ConsumerWidget {
  final Contact contact;

  const _ContactInformation({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DropdownOption> optionsCargo = [
      DropdownOption('', '--SELECCIONE--'),
      DropdownOption('01', 'ADMINISTRADOR'),
      DropdownOption('02', 'COMPRADOR'),
      DropdownOption('03', 'JEFE DE MANTENIMIENTO'),
      DropdownOption('04', 'JEFE DE PLANTA/ PRODUCCIÓN'),
      DropdownOption('05', 'OPERARIO/ TÉCNICO DE MANTENIMIENTO'),
      DropdownOption('06', 'GERENTE GENERAL'),
    ];

    final contactForm = ref.watch(contactFormProvider(contact));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empresa:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: contactForm.ruc.errorMessage != null
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _openSearch(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          //color: Colors.grey,
                          color: contactForm.ruc.errorMessage != null
                              ? Theme.of(context).colorScheme.error
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            contactForm.ruc.value == ''
                                ? 'Seleccione empresa'
                                : contactForm.razon,
                            //_selectedCompany.isEmpty ? 'Seleccione una empresa' : _selectedCompany,
                            style: TextStyle(
                                fontSize: 16,
                                color: contactForm.ruc.errorMessage != null
                                    ? Theme.of(context).colorScheme.error
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearch(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (contactForm.ruc.errorMessage != null)
                  Text(
                    contactForm.ruc.errorMessage ?? 'Requerido',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          CustomCompanyField(
            isTopField: true,
            label: 'Nombre *',
            initialValue: contactForm.contactoDesc.value,
            onChanged:
                ref.read(contactFormProvider(contact).notifier).onNameChanged,
            errorMessage: contactForm.contactoDesc.errorMessage,
          ),
          SelectCustomForm(
            label: 'Cargo',
            value: contactForm.contactoIdCargo,
            callbackChange: (String? newValue) {
              DropdownOption searchCargo =
                  optionsCargo.where((option) => option.id == newValue!).first;

              ref
                  .read(contactFormProvider(contact).notifier)
                  .onCargoChanged(newValue!);
              ref
                  .read(contactFormProvider(contact).notifier)
                  .onNombreCargoChanged(searchCargo.name);
            },
            items: optionsCargo,
          ),
          TitleSectionForm(title: 'DATOS DE CONTACTO'),
          CustomCompanyField(
            label: 'Teléfono *',
            initialValue: contactForm.contactoTelefonof.value,
            onChanged:
                ref.read(contactFormProvider(contact).notifier).onPhoneChanged,
            errorMessage: contactForm.contactoTelefonof.errorMessage,
          ),
          CustomCompanyField(
            label: 'Móvil *',
            initialValue: contactForm.contactoTelefonoc,
            onChanged: (String? newValue) {
              ref
                  .read(contactFormProvider(contact).notifier)
                  .onTelefonoNocChanged(newValue!);
            },
          ),
          CustomCompanyField(
            label: 'Email *',
            initialValue: contactForm.contactoEmail,
            onChanged: (String? newValue) {
              ref
                  .read(contactFormProvider(contact).notifier)
                  .onEmailChanged(newValue!);
            },
          ),
          CustomCompanyField(
            label: 'Comentarios',
            initialValue: contactForm.contactoNotas,
            onChanged: (String? newValue) {
              ref
                  .read(contactFormProvider(contact).notifier)
                  .onComentarioChanged(newValue!);
            },
            maxLines: 2,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, WidgetRef ref) async {
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

      ref.read(contactFormProvider(contact).notifier).onRucChanged(company.ruc);
      ref
          .read(contactFormProvider(contact).notifier)
          .onRazonChanged(company.razon);
    });
  }
}

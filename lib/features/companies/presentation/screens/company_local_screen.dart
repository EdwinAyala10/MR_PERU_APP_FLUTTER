import 'dart:async';

import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/domain/entities/create_update_company_local_response.dart';
import 'package:crm_app/features/companies/presentation/providers/forms/company_local_form_provider.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/select_custom_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyLocalScreen extends ConsumerWidget {
  final String id;

  const CompanyLocalScreen({super.key, required this.id});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyLocalState = ref.watch(companyLocalProvider(id));

    List<String> ids = id.split("*");
    String idCheck = ids[0];
    String ruc = ids[1];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crear Local'),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: companyLocalState.isLoading
            ? const FullScreenLoader()
            : _CompanyLocalView(
                companyLocal: companyLocalState.companyLocal!),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (companyLocalState.companyLocal == null) return;

            ref
                .read(companyLocalFormProvider(
                        companyLocalState.companyLocal!)
                    .notifier)
                .onFormSubmit()
                .then((CreateUpdateCompanyLocalResponse value) {
              //if ( !value.response ) return;
              if (value.message != '') {
                showSnackbar(context, value.message);
                if (value.response) {
                  Timer(const Duration(seconds: 3), () {
                    context.pop();
                    //context.push('/company_local/${ruc}');
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

class _CompanyLocalView extends ConsumerWidget {
  final CompanyLocal companyLocal;

  const _CompanyLocalView({required this.companyLocal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        SizedBox(height: 10),
        _CompanyLocalInformation(companyLocal: companyLocal),
      ],
    );
  }
}

class _CompanyLocalInformation extends ConsumerWidget {
  final CompanyLocal companyLocal;

  const _CompanyLocalInformation({required this.companyLocal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyLocalForm =
        ref.watch(companyLocalFormProvider(companyLocal));
        
    List<DropdownOption> optionsLocalTipo = [
      DropdownOption('', 'Seleccione tipo de local'),
      DropdownOption('2', 'PLANTA'),
    ];
    
    List<DropdownOption> optionsDepartamento = [
      DropdownOption('', 'Seleccione departamento'),
      DropdownOption('01', 'Lima'),
      DropdownOption('02', 'Callao'),
    ];

    List<DropdownOption> optionsProvincia = [
      DropdownOption('', 'Seleccione provincia'),
      DropdownOption('01', 'Lima'),
      DropdownOption('02', 'Callao'),
    ];

    List<DropdownOption> optionsDistrito = [
      DropdownOption('', 'Seleccione distrito'),
      DropdownOption('01', 'Ate'),
      DropdownOption('02', 'Barranco'),
      DropdownOption('03', 'Breña'),
      DropdownOption('04', 'Carabayllo'),
    ];


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
                    Chip(label: Text(companyLocalForm.razon ?? ''))
                  ],
                ),
              ),
            ],
          ),

          SelectCustomForm(
            label: 'Tipo de local',
            value: companyLocalForm.localTipo ?? '',
            callbackChange: (String? newValue) {
              ref
                  .read(companyLocalFormProvider(companyLocal).notifier)
                  .onTipoChanged(newValue!);
            },
            items: optionsLocalTipo,
          ),
          CustomCompanyField(
            label: 'Nombre de local',
            initialValue:
                companyLocalForm.localNombre.value,
            onChanged:
                ref.read(companyLocalFormProvider(companyLocal).notifier).onNombreChanged,
            errorMessage: companyLocalForm.localNombre.errorMessage,
          ),

          CustomCompanyField(
            label: 'Dirección',
            initialValue:
                companyLocalForm.localDireccion.value,
            onChanged:
                ref.read(companyLocalFormProvider(companyLocal).notifier).onDireccionChanged,
            errorMessage: companyLocalForm.localDireccion.errorMessage,
          ),

          SelectCustomForm(
            label: 'Departamento',
            value: companyLocalForm.localDepartamento ?? '',
            callbackChange: (String? newValue) {
              ref
                  .read(companyLocalFormProvider(companyLocal).notifier)
                  .onDepartamentoChanged(newValue!, '');
            },
            items: optionsDepartamento,
          ),
          SelectCustomForm(
            label: 'Provincia',
            value: companyLocalForm.localProvincia ?? '',
            callbackChange: (String? newValue) {
              ref
                  .read(companyLocalFormProvider(companyLocal).notifier)
                  .onProvinciaChanged(newValue!, '');
            },
            items: optionsProvincia,
          ),
          SelectCustomForm(
            label: 'Distrito',
            value: companyLocalForm.localDistrito ?? '',
            callbackChange: (String? newValue) {
              ref
                  .read(companyLocalFormProvider(companyLocal).notifier)
                  .onProvinciaChanged(newValue!, '');
            },
            items: optionsDistrito,
          ),
          const SizedBox(height: 10),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

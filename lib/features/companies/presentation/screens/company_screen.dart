import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
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

class CompanyScreen extends ConsumerWidget {
  final String rucId;

  const CompanyScreen({super.key, required this.rucId});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyProvider(rucId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Empresa'),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: companyState.isLoading
            ? const FullScreenLoader()
            : _CompanyView(company: companyState.company!),
        floatingActionButton: FloatingActionButtonCustom(
            callOnPressed: () {
              if (companyState.company == null) return;

              ref
                  .read(companyFormProvider(companyState.company!).notifier)
                  .onFormSubmit()
                  .then((CreateUpdateCompanyResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);
                  if (value.response) {
                    //Timer(const Duration(seconds: 3), () {
                    context.push('/companies');
                    //});
                  }
                }
              });
            },
            iconData: Icons.save),
      ),
    );
  }
}

class _CompanyView extends ConsumerWidget {
  final Company company;

  const _CompanyView({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        company != null
            ? _CompanyInformation(company: company)
            : const Center(
                child: Text('No se encontro información de la empresa'),
              )
      ],
    );
  }
}

class _CompanyInformation extends ConsumerWidget {
  final Company company;

  const _CompanyInformation({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DropdownOption> optionsTipoCliente = [
      DropdownOption('01', 'Proveedor'),
      DropdownOption('02', 'Distribuidor'),
      DropdownOption('03', 'Prospecto'),
      DropdownOption('04', 'Cliente'),
    ];

    List<DropdownOption> optionsEstado = [
      DropdownOption('A', 'ACTIVO'),
      DropdownOption('B', 'NO CLIENTE'),
    ];

    List<DropdownOption> optionsCalificacion = [
      DropdownOption('A', 'A'),
      DropdownOption('B', 'B'),
      DropdownOption('C', 'C'),
      DropdownOption('D', 'D'),
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

    List<DropdownOption> optionsLocalTipo = [
      DropdownOption('', 'Seleccione tipo de local'),
      DropdownOption('1', 'OFICINA FISCAL'),
      DropdownOption('2', 'PLANTA'),
      DropdownOption('3', 'OTROS'),
    ];

    final companyForm = ref.watch(companyFormProvider(company));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleSectionForm(title: 'GENERALES'),
          CustomCompanyField(
            label: 'Nombre de la empresa *',
            initialValue: companyForm.razon.value,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onRazonChanged,
            errorMessage: companyForm.razon.errorMessage,
          ),
          CustomCompanyField(
            label: 'RUC *',
            initialValue:
                companyForm.ruc.value == 'new' ? '' : companyForm.ruc.value,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onRucChanged,
            errorMessage: companyForm.ruc.errorMessage,
          ),
          SelectCustomForm(
            label: 'Tipo',
            value: companyForm.tipoCliente,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onTipoChanged(newValue!);
            },
            items: optionsTipoCliente,
          ),
          SelectCustomForm(
            label: 'Estado',
            value: companyForm.estado,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onEstadoChanged(newValue!);
            },
            items: optionsEstado,
          ),
          SelectCustomForm(
            label: 'Calificación',
            value: companyForm.calificacion,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onCalificacionChanged(newValue!);
            },
            items: optionsCalificacion,
          ),
          const SizedBox(height: 15),
          const Text('Responsable *'),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  companyForm.arrayresponsables!.isNotEmpty
                      ? Wrap(
                          spacing: 6.0,
                          children: companyForm.arrayresponsables != null
                              ? List<Widget>.from(companyForm.arrayresponsables!
                                  .map((item) => Chip(
                                        label: Text(item.userreportName ?? '',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        onDeleted: () {
                                          ref
                                              .read(companyFormProvider(company)
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Empresa visible para todos',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              Switch(
                value: companyForm.visibleTodos == '1' ? true : false,
                onChanged: (bool? newValue) {
                  ref
                      .read(companyFormProvider(company).notifier)
                      .onVisibleTodosChanged(newValue! ? '1' : '0');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomCompanyField(
            maxLines: 2,
            label: 'Comentarios',
            keyboardType: TextInputType.multiline,
            initialValue: companyForm.seguimientoComentario,
            onChanged: ref
                .read(companyFormProvider(company).notifier)
                .onComentarioChanged,
          ),
          CustomCompanyField(
            maxLines: 2,
            label: 'Recomendación',
            keyboardType: TextInputType.multiline,
            initialValue: companyForm.observaciones,
            onChanged: ref
                .read(companyFormProvider(company).notifier)
                .onRecomendacionChanged,
          ),
          TitleSectionForm(title: 'DATOS DE CONTACTO'),
          CustomCompanyField(
            isTopField: true,
            label: 'Teléfono',
            initialValue: companyForm.telefono.value,
            onChanged: ref
                .read(companyFormProvider(company).notifier)
                .onTelefonoChanged,
            errorMessage: companyForm.telefono.errorMessage,
          ),
          CustomCompanyField(
            isTopField: true,
            label: 'Email',
            initialValue: companyForm.email,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onEmailChanged,
          ),
          CustomCompanyField(
            isTopField: true,
            label: 'Web',
            initialValue: companyForm.website,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onWebChanged,
          ),
          TitleSectionForm(title: 'DIRECCIÓN DE EMPRESA'),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomCompanyField(
                    label: 'Dirección',
                    initialValue: companyForm.direccion.value,
                    onChanged: ref
                        .read(companyFormProvider(company).notifier)
                        .onDireccionChanged,
                    errorMessage: companyForm.direccion.errorMessage,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .blueAccent.shade200,
                      borderRadius: BorderRadius.circular(
                          8),
                    ),
                    child: IconButton(
                      splashColor: Colors.transparent,
                      onPressed: () {
                        showModalSearch(context, companyForm.rucId ?? '', 'direction');
                        //context.push('/company_map/${companyForm.rucId}/direction');
                      },
                      icon: const Icon(Icons.location_on,
                          color: Colors.white), 
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TitleSectionForm(title: 'DATOS DE PRIMER LOCAL'),
          SelectCustomForm(
            label: 'Tipo de local',
            value: companyForm.localTipo,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onTipoLocalChanged(newValue!);
            },
            items: optionsLocalTipo,
          ),
          const SizedBox(
            height: 4,
          ),
          CustomCompanyField(
            label: 'Nombre de local',
            initialValue: companyForm.localNombre,
            onChanged: ref
                .read(companyFormProvider(company).notifier)
                .onNombreLocalChanged,
          ),
          const SizedBox(
            height: 4,
          ),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomCompanyField(
                    label: 'Dirección de local',
                    initialValue: companyForm.localDireccion.value,
                    onChanged: ref
                        .read(companyFormProvider(company).notifier)
                        .onLocalDireccionChanged,
                    errorMessage: companyForm.localDireccion.errorMessage,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      splashColor: Colors.transparent,
                      onPressed: () {
                        showModalSearch(context, companyForm.rucId ?? '', 'direction-local');
                        //context.push('/company_map/${companyForm.rucId}/direction-local');
                      },
                      icon: const Icon(Icons.location_on, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SelectCustomForm(
            label: 'Departamento',
            value: companyForm.localDepartamento,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onDepartamentoChanged(newValue!);
            },
            items: optionsDepartamento,
          ),
          SelectCustomForm(
            label: 'Provincia',
            value: companyForm.localProvincia,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onProvinciaChanged(newValue!);
            },
            items: optionsProvincia,
          ),
          SelectCustomForm(
            label: 'Distrito',
            value: companyForm.localDistrito,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onProvinciaChanged(newValue!);
            },
            items: optionsDistrito,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<dynamic> showModalSearch(BuildContext context, String ruc, String identificator) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(14.0),
          //height: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Text(
                  'Seleccionar ubicación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Divider(),
              ListTile(
                title: const Center(
                    child:
                        Text('Usar mi ubicación actual')),
                onTap: () {
                  Navigator.pop(context);
                  //_openSearchContacts(context, ref);
                  context.push('/company_map/${ruc}/${identificator}');
                },
              ),
              const Divider(),
              ListTile(
                title: const Center(
                    child: Text('Buscar en el mapa')),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  //_openSearchUsers(context, ref);
                },
              ),
              const Divider(),
              const SizedBox(height: 6),
              ListTile(
                title: const Center(
                  child: Text(
                    'CANCELAR',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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

      ref.read(companyFormProvider(company).notifier).onUsuarioChanged(user);
    });
  }
}

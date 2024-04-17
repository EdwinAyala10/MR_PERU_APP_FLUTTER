import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/location/presentation/providers/gps_provider.dart';
import 'package:crm_app/features/location/presentation/providers/selected_map_provider.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/select_custom_form.dart';
import 'package:crm_app/features/shared/widgets/text_address.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyProvider(rucId));

    print('company state: ${companyState.company?.rucId}');
    print('company state name: ${companyState.company?.razon}');
    print('company state segComentario: ${companyState.company?.seguimientoComentario}');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${rucId == 'new' ? 'Crear' : 'Editar'} Empresa'),
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

    List<DropdownOption> optionsLocalTipo = [
      DropdownOption('', 'Seleccione tipo de local'),
      DropdownOption('2', 'PLANTA'),
    ];

    print('COMPANY 2: ${company}');
    print('COMPANY 2 RUC: ${company.rucId}');

    final companyForm = ref.watch(companyFormProvider(company));

    print('COMPANY FORM ID: ${companyForm.rucId}');
    print('COMPANY FORM RAZON: ${companyForm.razon.value}');
    //final selectMapState = ref.watch(selectedMapProvider.notifier).state;

    //print('selectMapState stateProcess: ${selectMapState.stateProcess}');
    //print('selectMapState module: ${selectMapState.module}');

    //var lat = selectMapState.location?.latitude;
    //var lng = selectMapState.location?.longitude;

    //if (selectMapState.stateProcess == 'updated' && selectMapState.module == 'direction') {
    /*ref
        .read(companyFormProvider(company).notifier)
        .onLoadAddressCompanyChanged(
          selectMapState.address ?? '',
          '${lat}, ${lng}',
          '${lat}',
          '${lng}',
          selectMapState.ubigeo ?? '',
          selectMapState.departament ?? '',
          selectMapState.province ?? '',
          selectMapState.district ?? '',
        );*/
    //}

    //if (selectMapState.stateProcess == 'updated' && selectMapState.module == 'direction-local') {
    /*ref
        .read(companyFormProvider(company).notifier)
        .onLoadAddressCompanyLocalChanged(
          selectMapState.address ?? '',
          '${lat}, ${lng}',
          '${lat}',
          '${lng}',
          selectMapState.ubigeo ?? '',
          selectMapState.departament ?? '',
          selectMapState.province ?? '',
          selectMapState.district ?? '',
        ); */
    //}

    TextEditingController _controllerNameLocal = TextEditingController();

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
              DropdownOption searchDropdown = optionsTipoCliente
                  .where((option) => option.id == newValue!)
                  .first;

              ref
                  .read(companyFormProvider(company).notifier)
                  .onTipoChanged(newValue!, searchDropdown.name);
            },
            items: optionsTipoCliente,
          ),
          SelectCustomForm(
            label: 'Estado',
            value: companyForm.estado,
            callbackChange: (String? newValue) {

              DropdownOption searchDropdown = optionsEstado
                  .where((option) => option.id == newValue!)
                  .first;

              ref
                  .read(companyFormProvider(company).notifier)
                  .onEstadoChanged(newValue!, searchDropdown.name);
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
          /*TextCustom(text: companyForm.codigoPostal, label: 'Código postal', placeholder: 'Código postal'),
          const SizedBox(
            height: 10,
          ),*/
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
          Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Nombre de local actual:',
                    style: TextStyle(
                        color: Colors.black54
                    )),
                  const SizedBox(width: 5),
                  Text(
                    companyForm.localNombre, 
                    style: const TextStyle(
                      color: Colors.black87
                    )
                  )
                ],
              ),
            const SizedBox(height: 10),
            ],
          ),
          const SizedBox(
            height: 4,
          ),

          TextAddress(
              text: companyForm.localDireccion.value,
              error: companyForm.localDireccion.errorMessage,
              placeholder: 'Dirección de local',
              callback: () {
                showModalSearch(context, ref, companyForm.rucId ?? '',
                    'direction-local', company);
                //context.push('/company_map/${companyForm.rucId}/direction');
              },
              paramContext: context),
          const SizedBox(
            height: 6,
          ),
          TextViewCustom(text: companyForm.localDepartamentoDesc, label: 'Departamento local', placeholder: 'Departamento del local'),
          TextViewCustom(text: companyForm.localProvinciaDesc, label: 'Provincia local', placeholder: 'Provincia del local'),
          TextViewCustom(text: companyForm.localDistritoDesc, label: 'Distrito local', placeholder: 'Distrito del local'),
          TextViewCustom(text: companyForm.localCodigoPostal ?? '', label: 'Código postal local', placeholder: 'Código postal del local'),
          
          TextViewCustom(text: companyForm.coordenadasLatitud ?? '', label: 'Latitud', placeholder: 'Latitud'),
          TextViewCustom(text: companyForm.coordenadasLongitud ?? '', label: 'Longitud', placeholder: 'Longitud'),
          /*SelectCustomForm(
            label: 'Departamento',
            value: companyForm.localDepartamento,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onDepartamentoChanged(newValue!);
            },
            items: optionsDepartamento,
          ),*/
          /*SelectCustomForm(
            label: 'Provincia',
            value: companyForm.localProvincia,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onProvinciaChanged(newValue!);
            },
            items: optionsProvincia,
          ),*/
          /*SelectCustomForm(
            label: 'Distrito',
            value: companyForm.localDistrito,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(company).notifier)
                  .onProvinciaChanged(newValue!);
            },
            items: optionsDistrito,
          ),*/
          const SizedBox(height: 85),
        ],
      ),
    );
  }

  Future<dynamic> showModalSearch(BuildContext context, WidgetRef ref,
      String ruc, String identificator, Company company) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
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
                title: const Center(child: Text('Usar mi ubicación actual')),
                onTap: () async {
                  Navigator.pop(modalContext);

                  final gpsState = ref.read(gpsProvider.notifier).state;

                  if (!gpsState.isAllGranted) {
                    if (!gpsState.isGpsEnabled) {
                      showSnackbar(context, 'Debe de habilitar el GPS');
                    } else {
                      showSnackbar(context, 'Es necesario el acceso a GPS');
                      ref.read(gpsProvider.notifier).askGpsAccess();
                    }
                    //Navigator.pop(context);

                    return;
                  }

                  showLoadingMessage(context);

                  //_openSearchContacts(context, ref);
                  final selectedMapNotifier =
                      ref.read(selectedMapProvider.notifier);
                  bool isNew = ruc == 'new' ? true : false;
                  await selectedMapNotifier.onSelectMapLocation(
                      true, isNew, ruc, 'company', identificator, company);

                  var stateSelectedMap = selectedMapNotifier.state;

                  var lat = stateSelectedMap.location?.latitude;
                  var lng = stateSelectedMap.location?.longitude;

                  if (identificator == 'direction') {
                    /*ref
                        .read(companyFormProvider(company).notifier)
                        .onLoadAddressCompanyChanged(
                          stateSelectedMap.address ?? '',
                          '${lat}, ${lng}',
                          '${lat}',
                          '${lng}',
                          stateSelectedMap.ubigeo ?? '',
                          stateSelectedMap.departament ?? '',
                          stateSelectedMap.province ?? '',
                          stateSelectedMap.district ?? '',
                        );*/
                  } else {
                    ref
                        .read(companyFormProvider(company).notifier)
                        .onLoadAddressCompanyLocalChanged(
                          stateSelectedMap.address ?? '',
                          '${lat}, ${lng}',
                          '${lat}',
                          '${lng}',
                          stateSelectedMap.ubigeo ?? '',
                          stateSelectedMap.departament ?? '',
                          stateSelectedMap.province ?? '',
                          stateSelectedMap.district ?? '',
                        );
                  }

                  selectedMapNotifier.onFreeIsUpdateAddress();
                  selectedMapNotifier.onChangeStateProcess('updated');

                  //context.push('/map');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Center(child: Text('Buscar en el mapa')),
                onTap: () async {
                  Navigator.pop(modalContext);
                  //_openSearchContacts(context, ref);
                  final selectedMapNotifier =
                      ref.read(selectedMapProvider.notifier);
                  bool isNew = ruc == 'new' ? true : false;
                  await selectedMapNotifier.onSelectMapLocation(
                      false, isNew, ruc, 'company', identificator, company);

                  context.push('/map');

                  // Cierra el modal
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
                  Navigator.pop(modalContext);
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

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}


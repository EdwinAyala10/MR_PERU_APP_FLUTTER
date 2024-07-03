import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';

import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../widgets/show_loading_message.dart';
import '../../../location/presentation/providers/gps_provider.dart';
import '../../../location/presentation/providers/selected_map_provider.dart';
import '../../../resource-detail/presentation/providers/resource_details_provider.dart';
import '../../../shared/domain/entities/dropdown_option.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';
import '../../../shared/widgets/text_address.dart';
import '../../../shared/widgets/title_section_form.dart';
import '../../../users/domain/domain.dart';
import '../../../users/presentation/delegates/search_user_delegate.dart';
import '../../../users/presentation/search/search_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyScreen extends ConsumerWidget {
  final String rucId;

  const CompanyScreen({super.key, required this.rucId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyProvider(rucId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${rucId == 'new' ? 'Crear' : 'Editar'} Empresa', style: const TextStyle(
            fontWeight: FontWeight.w700
          ),),
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

              showLoadingMessage(context);

              ref.read(companyProvider(rucId).notifier).isLoading();

              ref
                  .read(companyFormProvider(companyState.company!).notifier)
                  .onFormSubmit()
                  .then((CreateUpdateCompanyResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);
                  if (value.response) {
                    //Timer(const Duration(seconds: 3), () {
                    //context.push('/companies');
                    context.pop();
                    //});
                  }
                }

                Navigator.pop(context);

              });

              ref.read(companyProvider(rucId).notifier).isNotLoading();


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
        // ignore: unnecessary_null_comparison
        company != null
            ? _CompanyInformationv2(company: company)
            : const Center(
                child: Text('No se encontro información de la empresa'),
              )
      ],
    );
  }
}

class _CompanyInformationv2 extends ConsumerStatefulWidget {
  final Company company;

  const _CompanyInformationv2({required this.company});

  @override
  __CompanyInformationv2State createState() => __CompanyInformationv2State();
}

class __CompanyInformationv2State extends ConsumerState<_CompanyInformationv2> {
  late TextEditingController _controllerLocalName;
  late Key _fieldKeyLocalName;
  List<DropdownOption> optionsTipoCliente = [
    DropdownOption('', 'Cargando...')
  ];

  List<DropdownOption> optionsEstado = [
    DropdownOption('', 'Cargando...')
  ];

  List<DropdownOption> optionsCalificacion = [
    DropdownOption('', 'Cargando...')
  ];

  List<DropdownOption> optionsRubro = [
    DropdownOption('', 'Cargando...')
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador y la clave
    _controllerLocalName =
        TextEditingController(text: widget.company.localNombre);
    _fieldKeyLocalName = UniqueKey();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await ref.read(resourceDetailsProvider.notifier).loadCatalogById('02').then((value) => {
        setState(() {
          optionsTipoCliente = value;
        })
      });

      await ref.read(resourceDetailsProvider.notifier).loadCatalogById('03').then((value) => {
        setState(() {
          optionsEstado = value;
        })
      });

      await ref.read(resourceDetailsProvider.notifier).loadCatalogById('04').then((value) => {
        setState(() {
          optionsCalificacion = value;
        })
      });

      await ref.read(resourceDetailsProvider.notifier).loadCatalogById('16').then((value) => {
        setState(() {
          optionsRubro = value;
        })
      });

    });
  }

  @override
  void dispose() {
    // Dispose del controlador cuando ya no se necesita
    _controllerLocalName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<DropdownOption> optionsLocalTipo = [
      DropdownOption('', 'Seleccione tipo de local'),
      DropdownOption('2', 'PLANTA'),
    ];

    final companyForm = ref.watch(companyFormProvider(widget.company));
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

    /*ref.listen(companyFormProvider(widget.company), (previous, next) {
      print('previous.localNombre: ${previous?.localNombre}');
      print('next.localNombre: ${next.localNombre}');

      setState(() {
        _fieldKeyLocalName = UniqueKey();
        _controllerLocalName.text = next.localNombre;
      });

      //if (previous?.localNombre != next.localNombre) {
      //}

      // if ( next.errorMessage.isEmpty ) return;
      //showSnackbar( context, next.errorMessage );
    });*/

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleSectionForm(title: 'GENERALES'),
          CustomCompanyField(
            label: 'Nombre de la empresa *',
            initialValue: companyForm.razon.value,
            onChanged: ref
                .read(companyFormProvider(widget.company).notifier)
                .onRazonChanged,
            errorMessage: companyForm.razon.errorMessage,
          ),
          CustomCompanyField(
            label: 'RUC *',
            initialValue:
                companyForm.ruc.value == 'new' ? '' : companyForm.ruc.value,
            onChanged: ref
                .read(companyFormProvider(widget.company).notifier)
                .onRucChanged,
            errorMessage: companyForm.ruc.errorMessage,
          ),
          optionsRubro.length > 1 ? SelectCustomForm(
            label: 'Rubro',
            value: companyForm.idRubro.value,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(widget.company).notifier)
                  .onRubroChanged(newValue!);
            },
            items: optionsRubro,
            errorMessage: companyForm.idRubro.errorMessage,
          ): PlaceholderInput(text: 'Cargando Rubro...'),
          optionsTipoCliente.length > 1 ? SelectCustomForm(
            label: 'Tipo',
            value: companyForm.tipoCliente.value,
            callbackChange: (String? newValue) {
              DropdownOption searchDropdown = optionsTipoCliente
                  .where((option) => option.id == newValue!)
                  .first;

              ref
                  .read(companyFormProvider(widget.company).notifier)
                  .onTipoChanged(newValue!, searchDropdown.name);
            },
            items: optionsTipoCliente,
            errorMessage: companyForm.tipoCliente.errorMessage,
          ): PlaceholderInput(text: 'Cargando Tipo...'),
          optionsEstado.length > 1 ? SelectCustomForm(
            label: 'Estado',
            value: companyForm.estado.value,
            callbackChange: (String? newValue) {
              DropdownOption searchDropdown =
                  optionsEstado.where((option) => option.id == newValue!).first;

              ref
                  .read(companyFormProvider(widget.company).notifier)
                  .onEstadoChanged(newValue!, searchDropdown.name);
            },
            items: optionsEstado,
            errorMessage: companyForm.estado.errorMessage,
          ): PlaceholderInput(text: 'Cargando Estado...'),
          optionsCalificacion.length > 1 ? SelectCustomForm(
            label: 'Calificación',
            value: companyForm.calificacion.value,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(widget.company).notifier)
                  .onCalificacionChanged(newValue!);
            },
            items: optionsCalificacion,
            errorMessage: companyForm.calificacion.errorMessage,
          ): PlaceholderInput(text: 'Cargando Calificación...'),
          const SizedBox(height: 15),
          const Text('Responsable *', style: TextStyle(
            fontWeight: FontWeight.w600
          ),),
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
                                              .read(companyFormProvider(
                                                      widget.company)
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
                activeColor: secondaryColor,
                onChanged: (bool? newValue) {
                  ref
                      .read(companyFormProvider(widget.company).notifier)
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
                .read(companyFormProvider(widget.company).notifier)
                .onComentarioChanged,
          ),
          CustomCompanyField(
            maxLines: 2,
            label: 'Recomendación',
            keyboardType: TextInputType.multiline,
            initialValue: companyForm.observaciones,
            onChanged: ref
                .read(companyFormProvider(widget.company).notifier)
                .onRecomendacionChanged,
          ),
          TitleSectionForm(title: 'DATOS DE CONTACTO'),
          CustomCompanyField(
            isTopField: true,
            label: 'Teléfono',
            keyboardType: TextInputType.number,
            initialValue: companyForm.telefono.value,
            onChanged: ref
                .read(companyFormProvider(widget.company).notifier)
                .onTelefonoChanged,
            errorMessage: companyForm.telefono.errorMessage,
          ),
          CustomCompanyField(
            isTopField: true,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            initialValue: companyForm.email,
            onChanged: ref
                .read(companyFormProvider(widget.company).notifier)
                .onEmailChanged,
          ),
          CustomCompanyField(
            isTopField: true,
            label: 'Web',
            initialValue: companyForm.website,
            onChanged: ref
                .read(companyFormProvider(widget.company).notifier)
                .onWebChanged,
          ),
          /*TextCustom(text: companyForm.codigoPostal, label: 'Código postal', placeholder: 'Código postal'),
          const SizedBox(
            height: 10,
          ),*/
          TitleSectionForm(title: 'DATOS DE PRIMER LOCAL'),
          SelectCustomForm(
            label: 'Tipo de local',
            value: companyForm.localTipo.value,
            callbackChange: (String? newValue) {
              ref
                  .read(companyFormProvider(widget.company).notifier)
                  .onTipoLocalChanged(newValue!);
            },
            items: optionsLocalTipo,
            errorMessage: companyForm.localTipo.errorMessage,
          ),
          const SizedBox(
            height: 6,
          ),
          TextAddress(
              text: companyForm.localDireccion.value,
              error: companyForm.localDireccion.errorMessage,
              placeholder: 'Dirección de local',
              callback: () {
                showModalSearch(context, ref, companyForm.rucId ?? '',
                    'direction-local', widget.company);
                //context.push('/company_map/${companyForm.rucId}/direction');
              },
              paramContext: context),
          const SizedBox(
            height: 4,
          ),
          companyForm.isEditLocalNombre
              ? CustomCompanyField(
                  key: _fieldKeyLocalName,
                  label: 'Nombre de local',
                  initialValue: companyForm.localNombre,
                  controller: _controllerLocalName,
                  onChanged: ref
                      .read(companyFormProvider(widget.company).notifier)
                      .onNombreLocalChanged,
                )
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _fieldKeyLocalName = UniqueKey();
                      _controllerLocalName.text = companyForm.localNombre;
                    });

                    ref
                        .read(companyFormProvider(widget.company).notifier)
                        .onChangeEditLocalNombre();
                  },
                  child: TextViewCustom(
                      text: companyForm.localNombre,
                      label: 'Nombre de local',
                      placeholder: 'Nombre de local'),
                ),
          /*Column(
            children: [
              Row(
                children: [
                  const Text('Nombre de local actual:',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(width: 5),
                  Text(companyForm.localNombre,
                      style: const TextStyle(color: Colors.black87))
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),*/
          /*const SizedBox(
            height: 4,
          ),*/
          TextViewCustom(
              text: companyForm.localDepartamentoDesc,
              label: 'Departamento local',
              placeholder: 'Departamento del local'),
          TextViewCustom(
              text: companyForm.localProvinciaDesc,
              label: 'Provincia local',
              placeholder: 'Provincia del local'),
          TextViewCustom(
              text: companyForm.localDistritoDesc,
              label: 'Distrito local',
              placeholder: 'Distrito del local'),
          TextViewCustom(
              text: companyForm.localCodigoPostal ?? '',
              label: 'Código postal local',
              placeholder: 'Código postal del local'),
          TextViewCustom(
              text: companyForm.coordenadasLatitud,
              label: 'Latitud',
              placeholder: 'Latitud'),
          TextViewCustom(
              text: companyForm.coordenadasLongitud,
              label: 'Longitud',
              placeholder: 'Longitud'),
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

  @override
  void didUpdateWidget(covariant _CompanyInformationv2 oldWidget) {
    // Actualizar el controlador y la clave cuando el widget cambia
    _controllerLocalName.text = widget.company.localNombre!;
    _fieldKeyLocalName = UniqueKey();
    super.didUpdateWidget(oldWidget);
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
                          '$lat, $lng',
                          '$lat',
                          '$lng',
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

      ref
          .read(companyFormProvider(widget.company).notifier)
          .onUsuarioChanged(user);
    });
  }
}

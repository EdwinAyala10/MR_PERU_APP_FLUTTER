import 'dart:async';

import 'package:crm_app/features/shared/widgets/show_snackbar.dart';

import '../../domain/domain.dart';
import '../../domain/entities/create_update_company_local_response.dart';
import '../providers/forms/company_local_form_provider.dart';
import '../providers/providers.dart';
import '../widgets/show_loading_message.dart';
import '../../../location/presentation/providers/gps_provider.dart';
import '../../../location/presentation/providers/selected_map_provider.dart';
import '../../../shared/domain/entities/dropdown_option.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';
import '../../../shared/widgets/text_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyLocalScreen extends ConsumerWidget {
  final String id;

  const CompanyLocalScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyLocalState = ref.watch(companyLocalProvider(id));

    id.split("*");

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Local'),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: companyLocalState.isLoading
            ? const FullScreenLoader()
            : _CompanyLocalView(companyLocal: companyLocalState.companyLocal!),
        floatingActionButton: FloatingActionButtonCustom(
            callOnPressed: () {
              if (companyLocalState.companyLocal == null) return;

              ref
                  .read(
                      companyLocalFormProvider(companyLocalState.companyLocal!)
                          .notifier)
                  .onFormSubmit()
                  .then((CreateUpdateCompanyLocalResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);
                  if (value.response) {
                    //Timer(const Duration(seconds: 3), () {
                    ref.read(companiesProvider.notifier).loadAddressCompanyByRuc(companyLocalState.companyLocal?.ruc ?? '');
                    context.pop();

                    //context.push('/company_local/${ruc}');
                    //context.push('/company/${company.ruc}');
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

class _CompanyLocalView extends ConsumerWidget {
  final CompanyLocal companyLocal;

  const _CompanyLocalView({required this.companyLocal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        _CompanyLocalInformation(companyLocal: companyLocal),
      ],
    );
  }
}

class _CompanyLocalInformation extends ConsumerStatefulWidget {
  final CompanyLocal companyLocal;

  const _CompanyLocalInformation({required this.companyLocal});

  @override
  _CompanyLocalInformationState createState() =>
      _CompanyLocalInformationState();
}

class _CompanyLocalInformationState
    extends ConsumerState<_CompanyLocalInformation> {
  late TextEditingController _controllerLocalName;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador y la clave
    _controllerLocalName =
        TextEditingController(text: widget.companyLocal.localNombre);
  }

  @override
  void dispose() {
    // Dispose del controlador cuando ya no se necesita
    _controllerLocalName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var companyLocal = widget.companyLocal;

    final companyLocalForm = ref.watch(companyLocalFormProvider(companyLocal));

    List<DropdownOption> optionsLocalTipo = [
      DropdownOption('', 'Seleccione tipo de local'),
      DropdownOption('2', 'PLANTA'),
    ];

    /*ref.listen(companyLocalFormProvider(widget.companyLocal), (previous, next) {
      print('previous.localNombre: ${previous?.localNombre}');
      print('next.localNombre: ${next.localNombre}');

      setState(() {
        _fieldKeyLocalName = UniqueKey();
        _controllerLocalName.text = next.localNombre.value;
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
          const Text(
            'Empresa',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [Chip(label: Text(companyLocalForm.razon ?? ''))],
                ),
              ),
            ],
          ),
          SelectCustomForm(
            label: 'Tipo de local',
            value: companyLocalForm.localTipo ?? '',
            callbackChange: (String? newValue) {
              DropdownOption searchDropdown = optionsLocalTipo
                  .where((option) => option.id == newValue!)
                  .first;

              ref
                  .read(companyLocalFormProvider(companyLocal).notifier)
                  .onTipoChanged(newValue!, searchDropdown.name);
            },
            items: optionsLocalTipo,
          ),
          TextAddress(
              text: companyLocalForm.localDireccion.value,
              error: companyLocalForm.localDireccion.errorMessage,
              placeholder: 'Dirección de local',
              callback: () {
                showModalSearch(context, ref, companyLocalForm.id ?? '',
                    'direction-local', companyLocal);
                //context.push('/company_map/${companyForm.rucId}/direction');
              },
              paramContext: context),
          companyLocalForm.isEditLocalNombre!
              ? CustomCompanyField(
                  label: 'Nombre de local',
                  initialValue: companyLocalForm.localNombre.value,
                  controller: _controllerLocalName,
                  onChanged: ref
                      .read(companyLocalFormProvider(companyLocal).notifier)
                      .onNombreChanged,
                  errorMessage: companyLocalForm.localNombre.errorMessage,
                )
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllerLocalName.text =
                          companyLocalForm.localNombre.value;
                    });

                    ref
                        .read(companyLocalFormProvider(widget.companyLocal)
                            .notifier)
                        .onChangeEditLocalNombre();
                  },
                  child: TextViewCustom(
                      text: companyLocalForm.localNombre.value,
                      label: 'Nombre de local',
                      placeholder: 'Nombre de local'),
                ),
          const SizedBox(
            height: 4,
          ),
          /*if (companyLocalForm.localNombre.value != "UUUUU")
            Column(
              children: [
                Row(
                  children: [
                    const Text('Nombre de local actual:',
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(width: 5),
                    Text(companyLocalForm.localNombre.value,
                        style: const TextStyle(color: Colors.black87))
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),*/
          /*const SizedBox(
            height: 6,
          ),*/
          TextViewCustom(
              text: companyLocalForm.localDepartamentoDesc ?? '',
              label: 'Departamento local',
              placeholder: 'Departamento del local'),
          TextViewCustom(
              text: companyLocalForm.localProvinciaDesc ?? '',
              label: 'Provincia local',
              placeholder: 'Provincia del local'),
          TextViewCustom(
              text: companyLocalForm.localDistritoDesc ?? '',
              label: 'Distrito local',
              placeholder: 'Distrito del local'),
          TextViewCustom(
              text: companyLocalForm.localCodigoPostal ?? '',
              label: 'Código postal local',
              placeholder: 'Código postal del local'),
          TextViewCustom(
              text: companyLocalForm.coordenadasLatitud ?? '',
              label: 'Latitud',
              placeholder: 'Latitud'),
          TextViewCustom(
              text: companyLocalForm.coordenadasLongitud ?? '',
              label: 'Longitud',
              placeholder: 'Longitud'),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<dynamic> showModalSearch(BuildContext context, WidgetRef ref,
      String id, String identificator, CompanyLocal companyLocal) {
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
                  bool isNew = id == 'new' ? true : false;
                  await selectedMapNotifier.onSelectMapLocation(true, isNew, id,
                      'company-local', identificator, companyLocal);

                  var stateSelectedMap = selectedMapNotifier.state;

                  var lat = stateSelectedMap.location?.latitude;
                  var lng = stateSelectedMap.location?.longitude;

                  ref
                      .read(companyLocalFormProvider(companyLocal).notifier)
                      .onLoadAddressChanged(
                        stateSelectedMap.address ?? '',
                        '$lat, $lng',
                        '$lat',
                        '$lng',
                        stateSelectedMap.ubigeo ?? '',
                        stateSelectedMap.departament ?? '',
                        stateSelectedMap.province ?? '',
                        stateSelectedMap.district ?? '',
                      );

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
                  bool isNew = id == 'new' ? true : false;
                  await selectedMapNotifier.onSelectMapLocation(false, isNew,
                      id, 'company-local', identificator, companyLocal);

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
}

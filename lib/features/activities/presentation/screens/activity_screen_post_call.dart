import 'dart:async';
import 'dart:io';
import 'package:crm_app/call_duration_service.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/resource-detail/presentation/providers/resource_details_provider.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/domain.dart';
import '../providers/activity_call_provider.dart';
import '../providers/activity_post_call_provider.dart';
import '../providers/parameters/activity_post_call_params.dart';
import '../providers/providers.dart';
import '../../../opportunities/domain/domain.dart';
import '../../../shared/domain/entities/dropdown_option.dart';
import '../../../shared/shared.dart';

import '../../../opportunities/presentation/search/search_opportunities_active_provider.dart';
import '../../../opportunities/presentation/delegates/search_opportunity_active_delegate.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';

import 'package:intl/intl.dart';
import 'package:phone_state/phone_state.dart';

class ActivityPostCallScreen extends ConsumerWidget {
  final String contactId;
  final String phone;

  const ActivityPostCallScreen(
      {super.key, required this.contactId, required this.phone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final activityPostCallState = ref.watch(activityPostCallProvider(
        ActivityPostCallParams(contactId: contactId, phone: phone)));



    //final activityForm = ref.watch(activityFormProvider(activityPostCallState.activity));

    if (activityPostCallState.activity == null) {
      return const Scaffold(
        body: LoadingModal(),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informe post llamada', 
          style: TextStyle(fontWeight: FontWeight.w500)),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: activityPostCallState.isLoading
            ? const FullScreenLoader()
            : _ActivityView(
                activity: activityPostCallState.activity!, phone: phone),
        floatingActionButton: FloatingActionButtonCustom(
            iconData: Icons.save,
            //isDisabled: activityForm.actiComentario == '',
            callOnPressed: ref.watch(activityFormProvider(activityPostCallState.activity!)).actiComentario == '' ? () {
              showSnackbar(context, 'El comentario es requerido');
            } 
            : () {
              if (activityPostCallState.activity == null) return;
              showLoadingMessage(context);

              //activityPostCallState.activity?.actiIdTipoRegistro = '02';

              ref
                  .read(activityFormProvider(activityPostCallState.activity!)
                      .notifier)
                  .onFormSubmit()
                  .then((CreateUpdateActivityResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);

                  if (value.response) {
                    context.pop();
                    //Timer(const Duration(seconds: 3), () {
                    //context.push('/activities');
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

class _ActivityView extends ConsumerStatefulWidget {
  Activity activity;
  String phone;

  _ActivityView({Key? key, required this.activity, required this.phone})
      : super(key: key);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<_ActivityView> {
  PhoneState status = PhoneState.nothing();
  bool granted = false;

  List<DropdownOption> optionsTipoGestion = [
    DropdownOption(id: '', name: 'Cargando...')
  ];

  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();

    return switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited ||
      PermissionStatus.permanentlyDenied =>
        false,
      PermissionStatus.provisional || PermissionStatus.granted => true,
    };
  }

  final CallDurationService _callDurationService = CallDurationService();
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await ref.read(resourceDetailsProvider.notifier).loadCatalogVisibleById(groupId: '01', codigoId: '02').then((value) => {
        
        setState(() {
          //optionsTipoGestion = value.where((o) => o.id == '02' || o.id == '').toList();
          optionsTipoGestion = value;
        })
      });
    });
    
    _callDurationService.onCallEnded = (duration) {
      setState(() {
        _callDuration = duration;
      });
    };

    if (Platform.isIOS) setStream();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //ref.read(activitiesProvider.notifier).loadNextPage();
      _showModalBottomSheet(context, widget.phone, widget.activity);
      ref.read(activityCallProvider.notifier).loadActivityCall(widget.activity);
    });
  }


  void setStream() {

    PhoneState.stream.listen((event) {
      String? number = event.number;
      PhoneStateStatus statusCall = event.status;

      bool sendActivityCall = ref.read(activityCallProvider).sendActivityCall!;

      if (!sendActivityCall) {

        if (number == widget.phone &&
            statusCall == PhoneStateStatus.CALL_STARTED) {
          ref.read(activityCallProvider.notifier).onInitialCallChanged();
          //widget.activityPostCallState.onInitialCallChanged();
          /*ref
                .read(activityProvider(widget.activity).notifier)
                .onTipoGestionChanged(
                    newValue ?? '', searchTipoGestion.name);*/
        }

        if (number == widget.phone &&
            statusCall == PhoneStateStatus.CALL_ENDED) {

          ref.read(activityCallProvider.notifier).onFinishCallChanged();
          //widget.activityPostCallState.onFinishCallChanged();
        }
      }

      setState(() {
        status = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    /*List<DropdownOption> optionsTipoGestion = [
      DropdownOption(id: '', name: 'Selecciona'),
      //DropdownOption(id: '01', name: 'Comentario'),
      DropdownOption(id: '02', name: 'Llamada Telefónica'),
      //DropdownOption(id: '03', name: 'Reunión'),
      //DropdownOption(id: '04', name: 'Visita'),
    ];*/

    Activity activity = widget.activity;

    final activityForm = ref.watch(activityFormProvider(activity));

    return ListView(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Call Duration: $_callDuration seconds'),

              optionsTipoGestion.length > 1 ? SelectCustomForm(
                label: 'Tipo de gestión',
                value: activityForm.actiIdTipoGestion.value,
                callbackChange: (String? newValue) {
                  DropdownOption searchTipoGestion =
                      optionsTipoGestion.where((option) => option.id == newValue!).first;

                  ref
                      .read(activityFormProvider(activity).notifier)
                      .onTipoGestionChanged(
                          newValue ?? '', searchTipoGestion.name);
          
                },
                items: optionsTipoGestion,
                errorMessage: activityForm.actiIdTipoGestion.errorMessage,
              ): PlaceholderInput(text: 'Cargando Cargo...'),

              const SizedBox(height: 20),
              const Text(
                'DATOS DE LA GESTIÓN',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              TextViewCustom(
                  text: activityForm.actiRuc.value,
                  placeholder: 'Ruc',
                  label: 'RUC'),
              TextViewCustom(
                  text: activityForm.actiRazon,
                  placeholder: 'aaa',
                  label: 'Empresa'),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oportunidad',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: activityForm.actiIdOportunidad.value == '' ? Colors.red :  Colors.black
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        if (activityForm.actiRuc.value == null) {
                          showSnackbar(context, 'Seleccione una empresa');
                          return;
                        }
                        _openSearchOportunities(
                            context, ref, activityForm.actiRuc.value, activity);
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color: activityForm.actiIdOportunidad.value == '' ? Colors.red : Colors.black
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                if (activityForm.actiRuc.value == null) {
                                  showSnackbar(
                                      context, 'Seleccione una empresa');
                                  return;
                                }
                                _openSearchOportunities(context, ref,
                                    activityForm.actiRuc.value, activity);
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
              const SizedBox(height: 10),
              CustomCompanyField(
                label: 'Comentarios',
                maxLines: 2,
                initialValue: activityForm.actiComentario,
                onChanged: ref
                    .read(activityFormProvider(activity).notifier)
                    .onComentarioChanged,
              ),
              activityForm.actiComentario == ''
                  ? const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'El comentario es requerido',
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 10),
              const Text(
                'Contacto',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      activityForm.actividadesContacto!.isNotEmpty
                          ? Wrap(
                              spacing: 6.0,
                              children: activityForm.actividadesContacto != null
                                  ? List<Widget>.from(activityForm
                                      .actividadesContacto!
                                      .map((item) => Chip(
                                            label: Text(item.nombre ?? '',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            /*onDeleted: () {
                                              ref
                                                  .read(
                                                      activityFormProvider(activity)
                                                          .notifier)
                                                  .onDeleteContactoChanged(item);
                                            },*/
                                          )))
                                  : [],
                            )
                          : const Text('Seleccione contacto(s)',
                              style: TextStyle(color: Colors.black45)),
                    ],
                  )),
                ],
              ),
              activityForm.actividadesContacto!.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'Es requerido, seleccione contacto(s)',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 10),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 70),
            ],
          ),
        )
      ],
    );
  }

  void _openSearchOportunities(BuildContext context, WidgetRef ref, String ruc,
      Activity activity) async {
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
                    .searchOpportunitiesByQuery,
                resetSearchQuery: () {
                    ref.read(searchQueryOpportunitiesProvider.notifier).update((state) => '');
                },
            ))
        .then((opportunity) {
      if (opportunity == null) return;

      ref
          .read(activityFormProvider(activity).notifier)
          .onOportunidadChanged(opportunity.id, opportunity.oprtNombre);
    });
  }

  void _showModalBottomSheet(
      BuildContext context, String phone, Activity activity) {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Permitir cerrar al presionar en el fondo
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext contextInt) {
        return WillPopScope(
          onWillPop: () async {
            // Aquí puedes ejecutar la acción que quieras si se presiona el botón de retroceso
            print("Botón de retroceso presionado");
            // Devuelve false para evitar que el modal se cierre
            return false;
          },
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 10.0)),
                      onPressed: () {
                        Navigator.pop(context);
          
                        ref
                            .read(activityFormProvider(activity).notifier)
                            .onHoraChanged(
                                DateFormat('HH:mm:ss').format(DateTime.now()));
          
                        llamarTelefono(context, agregarPrefijoPeru(phone));
                      },
                      child: Text(
                        'Llamar ${agregarPrefijoPeru(phone)}',
                        style: const TextStyle(fontSize: 19, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 10.0)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        /*Timer(Duration(seconds: 3), () {
                          //Navigator.pop(context);
                          context.pop();
                        });*/
                        //context.pop();
                      },
                      child: const Text('CANCELAR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void llamarTelefono(BuildContext context, String phone) async {
    bool temp = await requestPermission();
    //setState(() async {
    //granted = temp;
    if (temp) {
      await FlutterPhoneDirectCaller.callNumber(phone);
      _callDurationService.makeCall(phone);
      setStream();
    } else {
      //bool? res = await FlutterPhoneDirectCaller.callNumber(phone);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo realizar la llamada')),
      );
    }
    //});
  }

  String agregarPrefijoPeru(String numero) {
    // Verificar si el número ya tiene el prefijo de país "+51"
    if (!numero.startsWith('+51')) {
      // Si no tiene el prefijo, agregarlo al principio
      return '+51$numero';
    }
    // Si ya tiene el prefijo, devolver el número sin cambios
    return numero;
  }
}


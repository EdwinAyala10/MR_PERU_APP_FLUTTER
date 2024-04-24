import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/providers/activity_call_provider.dart';
import 'package:crm_app/features/activities/presentation/providers/activity_post_call_provider.dart';
import 'package:crm_app/features/activities/presentation/providers/parameters/activity_post_call_params.dart';
import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';

import 'package:crm_app/features/opportunities/presentation/search/search_opportunities_active_provider.dart';
import 'package:crm_app/features/opportunities/presentation/delegates/search_opportunity_active_delegate.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/select_custom_form.dart';

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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informe post llamada'),
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
            callOnPressed: () {
              if (activityPostCallState.activity == null) return;

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

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) setStream();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //ref.read(activitiesProvider.notifier).loadNextPage();
      _showModalBottomSheet(context, widget.phone, widget.activity);
      ref.read(activityCallProvider.notifier).loadActivityCall(widget.activity);
    });
  }

  void setStream() {
    print(' SE ESTA EJECUTANDO SET STREAM');
    PhoneState.stream.listen((event) {
      String? number = event.number;
      PhoneStateStatus statusCall = event.status;

      print('STATUS REAL PHONE STATE NUMBER: ${event.number}');
      print('STATUS REAL PHONE STATE: ${event.status}');

      bool sendActivityCall = ref.read(activityCallProvider).sendActivityCall!;

      print('STATUS REAL: sendActivityCall: ${sendActivityCall}');

      if (!sendActivityCall) {
        print('STATUS REAL NUMBER: ${number} | PHONE: ${widget.phone}');

        if (number == widget.phone &&
            statusCall == PhoneStateStatus.CALL_STARTED) {
              print('STATUS REAL: INITIAL CALL SCREEN');
          ref.read(activityCallProvider.notifier).onInitialCallChanged();
          //widget.activityPostCallState.onInitialCallChanged();
          /*ref
                .read(activityProvider(widget.activity).notifier)
                .onTipoGestionChanged(
                    newValue ?? '', searchTipoGestion.name);*/
        }

        if (number == widget.phone &&
            statusCall == PhoneStateStatus.CALL_ENDED) {
              print('STATUS REAL: FIN CALL SCREEN');

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
    var scores = ['A', 'B', 'C', 'D'];

    List<String> tags = ['Aldo Mori'];

    List<DropdownOption> optionsTipoGestion = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', 'Comentario'),
      DropdownOption('02', 'Llamada Telefónica'),
      DropdownOption('03', 'Reunión'),
      DropdownOption('04', 'Visita'),
    ];

    Activity activity = widget.activity;

    final activityForm = ref.watch(activityFormProvider(activity));

    print('STATUS CALL: ${status.status}');

    return ListView(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SelectCustomForm(
                label: 'Tipo de gestión *',
                value: activityForm.actiIdTipoGestion.value,
                callbackChange: (String? newValue) {
                  DropdownOption searchTipoGestion = optionsTipoGestion
                      .where((option) => option.id == newValue!)
                      .first;
                  ref
                      .read(activityFormProvider(activity).notifier)
                      .onTipoGestionChanged(
                          newValue ?? '', searchTipoGestion.name);
                },
                items: optionsTipoGestion,
                errorMessage: activityForm.actiIdTipoGestion.errorMessage,
              ),
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
                    const Text(
                      'Oportunidad',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
                                style: const TextStyle(
                                  fontSize: 16,
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
              const SizedBox(height: 4),
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
                    .searchOpportunitiesByQuery))
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
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SizedBox(
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
                    },
                    child: const Text('CANCELAR'),
                  ),
                ),
              ],
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

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
import 'dart:async';

import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/location/presentation/providers/providers.dart';
import 'package:crm_app/features/resource-detail/presentation/providers/resource_details_provider.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/domain/entities/create_event_planner_response.dart';
import 'package:crm_app/features/route-planner/presentation/providers/forms/event_planner_form_provider.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/route-planner/presentation/widgets/route_card.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/format_distance.dart';
import 'package:crm_app/features/shared/widgets/format_from_seconds.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/domain/entities/dropdown_option.dart';

import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RegisterRoutePlannerScreen extends ConsumerWidget {

  const RegisterRoutePlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title:
                const Text('Planificador de rutas',
                style: TextStyle(
                  fontWeight: FontWeight.w600
                ),),
            /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
          ),
          body: const _EventView(),
          floatingActionButton: FloatingActionButtonCustom(
            callOnPressed:() {

              showLoadingMessage(context);

              ref
                  .read(eventPlannerFormProvider.notifier)
                  .onFormSubmit()
                  .then((CreateEventPlannerResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);

                  if (value.response) {
                    //Timer(const Duration(seconds: 3), () {
                    //TODO: LIMPIAR LOS SELECT ITEMS Y TODO EL FORMULARIO
                    ref.read(routePlannerProvider.notifier).clearSelectedLocales();
                    ref.read(routePlannerProvider.notifier).loadNextPage(isRefresh: false);
                    
                    context.replace('/route_planner');
                    //});
                  }
                }

                Navigator.pop(context);

              });

            }, 
            iconData: Icons.check),
      )
    );
  }
}

class _EventView extends ConsumerWidget {

  const _EventView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: const [
        SizedBox(height: 10),
        _EventPlannerInformation(),
      ],
    );
  }
}

class _EventPlannerInformation extends ConsumerStatefulWidget {
  const _EventPlannerInformation({super.key});

  @override
  ConsumerState<_EventPlannerInformation> createState() => _EventPlannerInformationState();
}

class _EventPlannerInformationState extends ConsumerState<_EventPlannerInformation> {
  List<DropdownOption> optionsTipoGestion = [
    DropdownOption(id: '', name: 'Selecciona'),
    DropdownOption(id: '04', name: 'Visita'),
  ];

  List<DropdownOption> optionsRecordatorio = [
    DropdownOption(id: '', name: 'Cargando...'),
  ];

  List<DropdownOption> optionsHorarioTrabajo = [
    DropdownOption(id: '', name: 'Cargando...'),
  ];

  List<DropdownOption> optionsTiempoEntreVisitas = [
    DropdownOption(id: '', name: 'Cargando...'),
  ];

  FilterOption? encontrarHorarioTrabajo(List<FilterOption> options) {
    try {
      return options.firstWhere(
        (option) => option.type == "HRTR_ID_HORARIO_TRABAJO",
      );
    } catch (e) {
      return null; // Manejo adicional si es necesario
    }
  }

  @override
  void initState() {

    WidgetsBinding.instance?.addPostFrameCallback((_) async {

      var filterSuccess =ref.read(routePlannerProvider).filtersSuccess;

      FilterOption? horarioTrabajo = encontrarHorarioTrabajo(filterSuccess);

      final totalDistance = ref.read(mapProvider).totalDistance;
      final totalDuration = ref.read(mapProvider).totalDuration;

      print('DATOS  XXX');
      print('totalDistance: ${totalDistance}');
      print('totalDuration: ${totalDuration}');

      String strDuracion = formatTimeFromSeconds(totalDuration);
      String strDistancia = formatDistanceV2(totalDistance);

      print('strDuracion: ${strDuracion}');
      print('strDistancia: ${strDistancia}');

      //SETEAR HORARIO TRABAJO
      await ref.watch(eventPlannerFormProvider.notifier).onChangeHorarioTrabajo(horarioTrabajo!.id, horarioTrabajo.name, strDuracion,strDistancia);
      
      String? dateIniHorario = await ref.read(routePlannerProvider).dateTimeInitial; 
      String? dateFinHorario = await ref.read(routePlannerProvider).dateTimeEnd; 

      DateTime dateInitialHorarioFormat = DateTime.parse(dateIniHorario ?? '');
      DateTime dateEndHorarioFormat = DateTime.parse(dateFinHorario ?? '');

      ref.watch(eventPlannerFormProvider.notifier).onFechaChanged(dateInitialHorarioFormat);
      ref.watch(eventPlannerFormProvider.notifier).onFechaTerminoChanged(dateEndHorarioFormat);
      
      print('INIT STATE REGISTER');
      print(horarioTrabajo.id);
      print(horarioTrabajo.name);
      //ref.read(eventPlannerFormProvider.notifier).onDurationAndDistanceChanged(strDuracion, strDistancia);

      await ref.read(resourceDetailsProvider.notifier).loadCatalogById('26').then((value) => {
        setState(() {
          optionsRecordatorio = value;
        })
      });
      /*await ref.read(resourceDetailsProvider.notifier).loadCatalogById('19').then((value) => {
        setState(() {
          optionsHorarioTrabajo = value;
        })
      });*/
      await ref.read(resourceDetailsProvider.notifier).loadCatalogById('25').then((value) => {
        setState(() {
          optionsTiempoEntreVisitas = value;
        })
      });
    });

    super.initState();

  }
  
  @override
  Widget build(BuildContext context) {
    final evenPlannertForm = ref.watch(eventPlannerFormProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          
          SelectCustomForm(
            label: 'Tipo de gestión',
            value: evenPlannertForm.evntIdTipoGestion.value.trim(),
            callbackChange: (String? newValue) {
              DropdownOption searchTipoGestion = optionsTipoGestion
                  .where((option) => option.id == newValue!)
                  .first;
              ref
                  .read(eventPlannerFormProvider.notifier)
                  .onTipoGestionChanged(newValue ?? '', searchTipoGestion.name);
            },
            items: optionsTipoGestion,
            errorMessage: evenPlannertForm.evntIdTipoGestion.errorMessage,
          ),// : PlaceholderInput(text: 'Cargando...'),
          
          const SizedBox(height: 10),
          const Text(
            'Fecha de Inicio',
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
                      DateFormat('dd-MM-yyyy').format(evenPlannertForm.evntFechaInicioEvento ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Fecha de Termino',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Center(
            child: GestureDetector(
              onTap: () => _selectDateTermino(context, ref),
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
                      DateFormat('dd-MM-yyyy').format(evenPlannertForm.evntFechaTerminoEvento ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              'Horario de Trabajo',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              '${evenPlannertForm.horarioTrabajoNombre}', 
            style: const TextStyle(
              fontSize: 16
            )),
          ),

          const SizedBox(height: 10),
          const Text('Hora programación',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          GestureDetector(
                  onTap: () => _selectTime(context, ref, 'inicio'),
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
                          DateFormat('hh:mm a').format(evenPlannertForm.evntHoraInicioEvento != null
                                  ? DateFormat('HH:mm:ss').parse(
                                      evenPlannertForm.evntHoraInicioEvento ?? '')
                                  : DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),

          const SizedBox(height: 10),
          optionsTiempoEntreVisitas.length > 1 ? SelectCustomForm(
            label: 'Tiempo entre visitas',
            value: evenPlannertForm.tiempoEntreVisitasId.value,
            callbackChange: (String? newValue) {
              DropdownOption searchRecordatorio = optionsTiempoEntreVisitas
                    .where((option) => option.id == newValue!)
                    .first;
                ref
                    .read(eventPlannerFormProvider.notifier)
                    .onTiempoEntreVisitaChanged(newValue!, searchRecordatorio.name);
            },
            items: optionsTiempoEntreVisitas,
            errorMessage: evenPlannertForm.tiempoEntreVisitasId.errorMessage,
          ): PlaceholderInput(text: 'Cargando...'),

          optionsRecordatorio.length > 1 ? SelectCustomForm(
            label: 'Tiempo de la visita',
            value: evenPlannertForm.evntIdIntervaloReunion.value,
            callbackChange: (String? newValue) {
              DropdownOption searchRecordatorio = optionsRecordatorio
                    .where((option) => option.id == newValue!)
                    .first;
                ref
                    .read(eventPlannerFormProvider.notifier)
                    .onTiempoReunionesChanged(newValue!, searchRecordatorio.name);
            },
            items: optionsRecordatorio,
            errorMessage: evenPlannertForm.evntIdIntervaloReunion.errorMessage,
          ): PlaceholderInput(text: 'Cargando...'),
          
          const Text(
            'Responsable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(
                        label: Text('${evenPlannertForm.evntNombreUsuarioResponsable}',
                    ))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          RouteCard(),
        ],
      ),
    );

  }
}

Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2101),
  );

  //if (picked != null && picked != selectedDate) {
  if (picked != null) {
    ref.read(eventPlannerFormProvider.notifier).onFechaChanged(picked);
  }
}

Future<void> _selectDateTermino(BuildContext context, WidgetRef ref) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2101),
  );

  //if (picked != null && picked != selectedDate) {
  if (picked != null) {
    ref.read(eventPlannerFormProvider.notifier).onFechaTerminoChanged(picked);
  }
}

Future<void> _selectTime(
    BuildContext context, WidgetRef ref, String type) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  //if (picked != null && picked != selectedDate) {
  if (picked != null) {
    String formattedTime = '${picked.toString().substring(10, 15)}:00';

    //if (type == 'inicio') {
      ref
          .read(eventPlannerFormProvider.notifier)
          .onHoraInicioChanged(formattedTime);
    //}

    
  }
}

import 'dart:async';

import 'package:crm_app/features/route-planner/presentation/widgets/route_card.dart';

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
    //final eventState = ref.watch(eventProvider(eventId));

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
        _EventInformation(),
      ],
    );
  }
}

class _EventInformation extends ConsumerWidget {
  const _EventInformation();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DropdownOption> optionsTipoGestion = [
      DropdownOption(id: '', name: 'Selecciona'),
      DropdownOption(id: '01', name: 'Comentario'),
      DropdownOption(id: '02', name: 'Llamada Telefónica'),
      DropdownOption(id: '03', name: 'Reunión'),
      DropdownOption(id: '04', name: 'Visita'),
    ];

    List<DropdownOption> optionsRecordatorio = [
      DropdownOption(id: '', name: 'Selecciona'),
      DropdownOption(id: '1', name: '5 MINUTOS ANTES'),
      DropdownOption(id: '2', name: '15 MINUTOS ANTES'),
      DropdownOption(id: '3', name: '30 MINUTOS ANTES'),
      DropdownOption(id: '4', name: '1 DIA ANTES'),
      DropdownOption(id: '5', name: '1 SEMANA ANTES'),
    ];



    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SelectCustomForm(
            label: 'Tipo de gestión',
            value: '',
            callbackChange: (String? newValue) {
              
            },
            items: optionsTipoGestion,
          ),
          
          const SizedBox(height: 10),
          const Text(
            'Fecha',
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
                      DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Hora',
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
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
    
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Tiempo entre reuniones',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: '',
                      onChanged: (String? newValue) {
                        
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      // Mapeo de las opciones a elementos de menú desplegable
                      items: optionsRecordatorio.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Email de usuarios externos',
            initialValue: eventForm.evntCorreosExternos ?? '',
            onChanged: ref
                .read(eventFormProvider(event).notifier)
                .onCorreosExternosChanged,
          ),*/
          //const Text('  ingresar emails separado por comas (,)',
          //    style: TextStyle(fontSize: 12, color: Colors.black45)),
          //const SizedBox(height: 30),
          /*const Text(
            'DIRECCIÓN',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),*/
          const SizedBox(height: 30),
          const Text(
            'Responsable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(
                        label: Text('Admin',
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

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    //print(picked);

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      //ref.read(eventFormProvider(event).notifier).onFechaChanged(picked);
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

      if (type == 'inicio') {
        /*ref
            .read(eventFormProvider(event).notifier)
            .onHoraInicioChanged(formattedTime);*/
      }

     
    }
  }

}

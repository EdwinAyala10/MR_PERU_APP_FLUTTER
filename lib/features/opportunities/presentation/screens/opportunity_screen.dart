import 'dart:async';

import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OpportunityScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityScreen({super.key, required this.opportunityId});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityState = ref.watch(opportunityProvider(opportunityId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Oportunidad'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: opportunityState.isLoading
            ? const FullScreenLoader()
            : _OpportunityView(opportunity: opportunityState.opportunity!),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (opportunityState.opportunity == null) return;

            ref
                .read(opportunityFormProvider(opportunityState.opportunity!).notifier)
                .onFormSubmit()
                .then((CreateUpdateOpportunityResponse value) {
              //if ( !value.response ) return;
              if (value.message != '') {
                showSnackbar(context, value.message);

                if (value.response) {
                  Timer(const Duration(seconds: 3), () {
                    context.push('/opportunities');
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

class _OpportunityView extends ConsumerWidget {
  final Opportunity opportunity;

  const _OpportunityView({required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ListView(
      children: [
        const SizedBox(height: 10),
        _OpportunityInformation(opportunity: opportunity),
      ],
    );
  }
}

class _OpportunityInformation extends ConsumerWidget {
  final Opportunity opportunity;

  const _OpportunityInformation({required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> tags = ['Responsable 1', 'Responsable 2', 'Responsable 3'];

    List<DropdownOption> optionsEstado = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', '1. Contactado'),
      DropdownOption('02', '2. Primera visista'),
      DropdownOption('03', '3. Oferta enviada'),
      DropdownOption('04', '4. Esperando pedido'),
    ];

    List<DropdownOption> optionsMoneda = [
      DropdownOption('01', 'USD'),
      DropdownOption('02', 'PEN'),
    ];

    final opportunityForm = ref.watch(opportunityFormProvider(opportunity));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          CustomCompanyField(
            isTopField: true,
            label: 'Nombre de la oportunidad *',
            initialValue: opportunityForm.oprtNombre.value,
            onChanged:
                ref.read(opportunityFormProvider(opportunity).notifier).onNameChanged,
            errorMessage: opportunityForm.oprtNombre.errorMessage,
          ),
          const SizedBox(height: 10 ),

          const Text('DATOS DE OPORTUNIDAD'),
          const SizedBox(height: 10 ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Estado:',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 180, // Ancho específico para el DropdownButton
                  child: DropdownButton<String>(
                    // Valor seleccionado
                    value: opportunityForm.oprtIdEstadoOportunidad,
                    onChanged: (String? newValue) {
                      ref
                          .read(opportunityFormProvider(opportunity).notifier)
                          .onIdEstadoChanged(newValue!);
                      
                    },
                    //value: optionsEstado.estado,
                    /*onChanged: (String? newValue) {
                      ref
                          .read(companyFormProvider(company).notifier)
                          .onEstadoChanged(newValue!);
                    },*/
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    // Mapeo de las opciones a elementos de menú desplegable
                    items: optionsEstado.map((option) {
                      return DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.name),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10 ),

          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Probalidad: ${double.parse(opportunityForm.oprtProbabilidad ?? '0').round()}%',
                  style: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.w600),
                  
                ),
                const SizedBox(height: 10.0),
                Slider(
                  value: double.parse(opportunityForm.oprtProbabilidad),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${double.parse(opportunityForm.oprtProbabilidad).round()}%',
                  onChanged: (double value) {
                    ref
                          .read(opportunityFormProvider(opportunity).notifier)
                          .onProbabilidadChanged(value.toString());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10 ),


          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Moneda:',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: opportunityForm.oprtIdValor,
                  onChanged: (String? newValue) {
                      DropdownOption searchEstado = optionsEstado.where((option) => option.id == newValue!).first;
                      
                      ref
                          .read(opportunityFormProvider(opportunity).notifier)
                          .onIdValorChanged(newValue!);
                      ref
                          .read(opportunityFormProvider(opportunity).notifier)
                          .onValorChanged(searchEstado.name);
                  },
                  //value: optionsEstado.estado,
                  /*onChanged: (String? newValue) {
                    ref
                        .read(companyFormProvider(company).notifier)
                        .onEstadoChanged(newValue!);
                  },*/
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                  // Mapeo de las opciones a elementos de menú desplegable
                  items: optionsMoneda.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.id,
                      child: Text(option.name),
                    );
                  }).toList(),
                ),
               
              ],
            ),
          ),
          
          const SizedBox(height: 10 ),

          const CustomCompanyField(
            label: 'Importe Total',
            initialValue: '0',
          ),
          const SizedBox(height: 10 ),
          DateField(),
          const SizedBox(height: 10 ),
        
          const SizedBox(height: 10 ),
          CustomCompanyField(
            label: 'Empresa principal',
            initialValue: opportunityForm.oprtRuc,
            onChanged:
                ref.read(opportunityFormProvider(opportunity).notifier).onRucChanged,
          ),
          const SizedBox(height: 10 ),

          CustomCompanyField(
            label: 'Intermediario',
            initialValue: opportunityForm.oprtRucIntermediario01,
            onChanged:
                ref.read(opportunityFormProvider(opportunity).notifier).onRucIntermediario01Changed,
          ),


          const SizedBox(height: 15),
          const Text('Responsable *'),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: List.generate(
                    tags.length,
                    (index) => Chip(
                      label: Text(tags[index]),
                      onDeleted: () {},
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Icon(Icons.add),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20 ),

          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: opportunityForm.oprtComentario,
            onChanged:
                ref.read(opportunityFormProvider(opportunity).notifier).onComentarioChanged,
          ),
          
          const SizedBox(height: 10),
          /*Center(
          child: DropdownButton<String>(
            value: scores.first,
            onChanged: (String? newValue) {
              print('Nuevo valor seleccionado: $newValue');
            },
            items: scores.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),*/

          const SizedBox(height: 100 ),
          
        ],
      ),
    );
  }
}

class DropdownOption {
  final String id;
  final String name;

  DropdownOption(this.id, this.name);
}



class DateField extends StatefulWidget {
  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    print(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          initialValue: '2024-12-01',
          readOnly: true, // El campo de texto es solo de lectura
          onTap: () => _selectDate(
              context), // Abre el selector de fecha cuando se toca el campo
          decoration: const InputDecoration(
            labelText: 'Fecha',
            prefixIcon: Icon(Icons.calendar_today), // Icono del calendario
            border: OutlineInputBorder(), // Estilo del borde del campo
          ),
        ),
      ],
    );
  }
}
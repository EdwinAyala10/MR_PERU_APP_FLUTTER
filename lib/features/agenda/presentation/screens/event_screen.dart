import 'package:crm_app/features/shared/widgets/custom_company_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventScreen extends ConsumerWidget {
  const EventScreen({super.key});

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento creado correctamente.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Evento'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.go('/agenda');
            },
          ),
        ),
        body: const _OpportunityView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showSnackbar(context);
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}

class _OpportunityView extends ConsumerWidget {
  const _OpportunityView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: const [
        SizedBox(height: 10),
        OpportunityInformation(),
      ],
    );
  }
}

class OpportunityInformation extends ConsumerWidget {
  const OpportunityInformation({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var scores = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const CustomCompanyField(
            isTopField: true,
            label: 'Asunto *',
            initialValue: '',
          ),
          const SizedBox(height: 10),
          const CustomCompanyField(
            label: 'Tipo de gestión',
            initialValue: '',
          ),
          const SizedBox(height: 10),
          const CustomCompanyField(
            label: 'Empresa',
            initialValue: '',
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('¿Todo el día?'),
              Switch(
                value: false,
                onChanged: (bol) {
                  print('${bol}');
                },
              ),
            ],
          ),
          /*InputDatePickerFormField(
            fieldLabelText: 'Fecha',
            initialDate: DateTime.now(),
            onDateSubmitted: (date) {
              
            },
            onDateSaved: (date) {
              
            }, 
            firstDate: DateTime(DateTime.now().year - 120), 
            lastDate: DateTime.now(),
          ),*/
          DateField(),
          const SizedBox(height: 10),
          TimeField(),
          const SizedBox(height: 10),
          const CustomCompanyField(
            label: 'Recordatorio de cita',
            initialValue: '',
          ),
          const SizedBox(height: 10),
          const CustomCompanyField(
            label: 'Responsable',
            initialValue: '',
          ),
          const SizedBox(height: 10),
          const CustomCompanyField(
            label: 'Empresa',
            initialValue: '',
          ),
          const SizedBox(height: 10),
          const CustomCompanyField(
            label: 'Oportunidad',
            initialValue: '',
          ),
          const SizedBox(height: 20),
          const CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
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

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String selectedType;
  final void Function(String selectedType) onTypeChanged;

  final List<String> types = const ['Hombre', 'Mujer', 'Otros'];
  final List<IconData> genderIcons = const [
    Icons.man,
    Icons.woman,
    Icons.boy,
  ];

  const _TypeSelector(
      {required this.selectedType, required this.onTypeChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: types.map((size) {
          return ButtonSegment(
              //icon: Icon( genderIcons[ types.indexOf(size) ] ),
              value: size,
              label: Text(size, style: const TextStyle(fontSize: 12)));
        }).toList(),
        selected: {selectedType},
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus();
          onTypeChanged(newSelection.first);
        },
      ),
    );
  }
}

class _StateSelector extends StatelessWidget {
  final String selectedState;
  final void Function(String selectedState) onStateChanged;

  final List<String> states = const [
    'Activo',
    'No Cliente',
  ];
  final List<IconData> stateIcons = const [
    Icons.circle,
    Icons.circle,
  ];

  const _StateSelector(
      {required this.selectedState, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: states.map((size) {
          return ButtonSegment(
              //icon: Icon( genderIcons[ types.indexOf(size) ] ),
              value: size,
              label: Text(size, style: const TextStyle(fontSize: 12)));
        }).toList(),
        selected: {selectedState},
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus();
          onStateChanged(newSelection.first);
        },
      ),
    );
  }
}

class _ScoreSelector extends StatelessWidget {
  final String selectedScore;
  final void Function(String selectedScore) onScoreChanged;

  final List<String> states = const [
    'A',
    'B',
    'C',
    'D',
  ];

  const _ScoreSelector(
      {required this.selectedScore, required this.onScoreChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: states.map((size) {
          return ButtonSegment(
              //icon: Icon( genderIcons[ types.indexOf(size) ] ),
              value: size,
              label: Text(size, style: const TextStyle(fontSize: 12)));
        }).toList(),
        selected: {selectedScore},
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus();
          onScoreChanged(newSelection.first);
        },
      ),
    );
  }
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
          //controller: _dateController,
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


class TimeField extends StatefulWidget {
  @override
  _TimeFieldState createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  //TextEditingController _timeController = TextEditingController();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    print(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          //controller: _timeController,
          readOnly: true, // El campo de texto es solo de lectura
          onTap: () => _selectTime(context), // Abre el selector de hora cuando se toca el campo
          decoration: const InputDecoration(
            labelText: 'Hora',
            prefixIcon: Icon(Icons.access_time), // Icono de la hora
            border: OutlineInputBorder(), // Estilo del borde del campo
          ),
        ),
      ],
    );
  }
}
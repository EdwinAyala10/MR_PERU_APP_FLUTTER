import 'package:crm_app/features/shared/widgets/custom_company_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActivityScreen extends ConsumerWidget {
  final String activityId;

  const ActivityScreen({super.key, required this.activityId});

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad creada correctamente.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Actividad'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: const _ActivityView(),
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

class _ActivityView extends ConsumerWidget {
  const _ActivityView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: const [
        SizedBox(height: 10),
        ActivityInformation(),
      ],
    );
  }
}

class ActivityInformation extends ConsumerWidget {
  const ActivityInformation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var scores = ['A', 'B', 'C', 'D'];

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),

          CustomCompanyField(
            isTopField: true,
            label: 'Nombre de la oportunidad *',
            initialValue: '',
          ),
          SizedBox(height: 10 ),

          Text('DATOS DE OPORTUNIDAD'),
          SizedBox(height: 20),
          CustomCompanyField(
            label: 'Entorno',
            initialValue: '',
          ),
          SizedBox(height: 10 ),
          CustomCompanyField(
            label: 'Estado de oportunidad *',
            initialValue: '',
          ),
          SizedBox(height: 10 ),
          CustomCompanyField(
            label: 'Probabilidad de venta (%)',
            initialValue: '',
          ),
          SizedBox(height: 10 ),
          CustomCompanyField(
            label: 'Divisa',
            initialValue: '',
          ),
          SizedBox(height: 10 ),
          CustomCompanyField(
            label: 'Importe total',
            initialValue: '',
          ),
          SizedBox(height: 10 ),
          CustomCompanyField(
            label: 'Fecha prevista de venta',
            initialValue: '',
          ),
          SizedBox(height: 10 ),
        
          Text('REFERENCIAS'),
          SizedBox(height: 20),

          SizedBox(height: 10 ),
          CustomCompanyField(
            label: 'Responsable *',
            initialValue: '',
          ),
          SizedBox(height: 10 ),

          CustomCompanyField(
            label: 'Empresa principal',
            initialValue: '',
          ),
          SizedBox(height: 10 ),
          
          CustomCompanyField(
            label: 'Intermediario',
            initialValue: '',
          ),
          SizedBox(height: 10 ),

          CustomCompanyField(
            label: 'Otros',
            initialValue: '',
          ),
          SizedBox(height: 20 ),

          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
          ),
          
          SizedBox(height: 10),
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

          SizedBox(height: 10 ),
          
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String selectedType;
  final void Function(String selectedType) onTypeChanged;

  final List<String> types = const [
    'Hombre',
    'Mujer',
    'Otros'
  ];
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

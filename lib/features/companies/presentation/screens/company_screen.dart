import 'package:crm_app/features/shared/widgets/custom_company_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyScreen extends ConsumerWidget {
  final String companyId;

  const CompanyScreen({super.key, required this.companyId});

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empresa creada correctamente.')));
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Empresa'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: const _CompanyView(),
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

class _CompanyView extends ConsumerWidget {
  const _CompanyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: const [
        SizedBox(height: 10),
        CompanyInformation(),
      ],
    );
  }
}

class CompanyInformation extends ConsumerWidget {
  const CompanyInformation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var scores = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generales'),
          const SizedBox(height: 20),
          const CustomCompanyField(
            isTopField: true,
            label: 'Nombre de la empresa *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),

          const CustomCompanyField(
            label: 'RUC *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),

          const CustomCompanyField(
            label: 'Entorno *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),

          Padding(
            padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Tipo:', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                  DropdownButton<String>(
                    value: 'Cliente',
                    onChanged: (String? newValue) {
                      print(newValue);
                    },
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1)
                    ),
                    items: <String>['Proveedor', 'Distribuidor', 'Prospecto', 'Cliente']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Estado:', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                  DropdownButton<String>(
                    value: 'Activo',
                    onChanged: (String? newValue) {
                      print(newValue);
                    },
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1)
                    ),
                    items: <String>['Activo', 'No Cliente']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ),
         
          const SizedBox(height: 10 ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Calificación', 
              style: TextStyle( fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold ),
            ),
          ),
          const SizedBox(height: 5 ),

          _ScoreSelector(
            selectedScore: 'A',
            onScoreChanged: (String text) =>  print('change ${text}'),
          ),
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

          const SizedBox(height: 15),
          const Text('Extras'),
          const SizedBox(height: 15),
          const CustomCompanyField(
            isTopField: true,
            label: 'Responsable',
            initialValue: '',
          ),
          const SizedBox(height: 10),

          const CustomCompanyField(
            label: 'Dirección',
            initialValue: '',
          ),
          const SizedBox(height: 10),

          const CustomCompanyField(
            maxLines: 6,
            label: 'Comentarios',
            keyboardType: TextInputType.multiline,
            initialValue: '',
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String selectedType;
  final void Function(String selectedType) onTypeChanged;

  final List<String> types = const [
    'Proveedor',
    'Distribuidor',
    'Prospecto',
    'Cliente'
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

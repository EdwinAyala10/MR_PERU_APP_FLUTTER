import 'package:crm_app/features/shared/widgets/custom_company_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ContactScreen extends ConsumerWidget {
  final String contactId;

  const ContactScreen({super.key, required this.contactId});

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
          title: const Text('Crear Contacto'),
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

    List<DropdownOption> optionsGenero = [
      DropdownOption('01', 'Mujer'),
      DropdownOption('02', 'Hombre'),
    ];

    List<DropdownOption> optionsCargo = [
      DropdownOption('01', 'ADMINISTRADOR'),
      DropdownOption('02', 'VENDEDOR'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información'),
          const SizedBox(height: 20),

          const CustomCompanyField(
            isTopField: true,
            label: 'Nombre *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),

          const CustomCompanyField(
            label: 'Apellidos *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),

          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Género:',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 180, // Ancho específico para el DropdownButton
                  child: DropdownButton<String>(
                    // Valor seleccionado
                    value: '02',
                    onChanged: (String? newValue) {
                      
                    },
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    // Mapeo de las opciones a elementos de menú desplegable
                    items: optionsGenero.map((option) {
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

          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Cargo:',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 180, // Ancho específico para el DropdownButton
                  child: DropdownButton<String>(
                    // Valor seleccionado
                    value: '02',
                    onChanged: (String? newValue) {
                      
                    },
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    // Mapeo de las opciones a elementos de menú desplegable
                    items: optionsCargo.map((option) {
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

          const CustomCompanyField(
            isTopField: true,
            label: 'Empresa *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),

          const Text('DATOS DE CONTACTO'),
          const SizedBox(height: 20),
          const CustomCompanyField(
            label: 'Teléfono *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),
          const CustomCompanyField(
            label: 'Móvil *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),
          const CustomCompanyField(
            label: 'Email *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),
          const CustomCompanyField(
            label: 'Skype *',
            initialValue: '',
          ),
          const SizedBox(height: 10 ),
          const CustomCompanyField(
            label: 'Linkedin *',
            initialValue: '',
          ),

          const SizedBox(height: 10 ),
          const CustomCompanyField(
            label: 'Comentarios',
            initialValue: '',
            maxLines: 2,
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

class DropdownOption {
  final String id;
  final String name;

  DropdownOption(this.id, this.name);
}

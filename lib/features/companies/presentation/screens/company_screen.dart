import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/custom_company_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyScreen extends ConsumerWidget {
  final String ruc;

  const CompanyScreen({super.key, required this.ruc});

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empresa creada correctamente.')));
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final companyState = ref.watch( companyProvider(ruc) );

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
        body: _CompanyView(ruc: ruc),
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
  final String ruc;
  
  const _CompanyView({required this.ruc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    final companyState = ref.watch( companyProvider(ruc) );

    return companyState.isLoading 
      ? const FullScreenLoader()
      : ListView(
      children: [
        SizedBox(height: 10),
        CompanyInformation(company: companyState.company! ),
      ],
    );
  }
}

class CompanyInformation extends ConsumerWidget {
  
  final Company company;

  const CompanyInformation({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var scores = ['A', 'B', 'C', 'D'];
    List<String> tags = ['Responsable 1', 'Responsable 2', 'Responsable 3'];

    final companyForm = ref.watch( companyFormProvider(company) );


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
          
          Padding(
            padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Tipo:', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
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
                  const Text('Estado:', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Calificación:', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 150, // Ancho específico para el DropdownButton
                  child: DropdownButton<String>(
                    value: 'A',
                    onChanged: (String? newValue) {
                      print(newValue);
                    },
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1)
                    ),
                    items: <String>['A', 'B', 'C', 'D']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
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
                      onDeleted: () {
                       
                      },
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                 
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Empresa visible para todos',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              Switch(
                value: true,
                onChanged: (bool newValue) {
                  
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          const CustomCompanyField(
            maxLines: 2,
            label: 'Comentarios',
            keyboardType: TextInputType.multiline,
            initialValue: '',
          ),
          
          const SizedBox(height: 20),

          const CustomCompanyField(
            maxLines: 3,
            label: 'Recomendación',
            keyboardType: TextInputType.multiline,
            initialValue: '',
          ),

          const SizedBox(height: 15),
          const Text('Datos de contacto'),

          const SizedBox(height: 15),
          const CustomCompanyField(
            isTopField: true,
            label: 'Email',
            initialValue: '',
          ),
          const SizedBox(height: 10),

          const CustomCompanyField(
            isTopField: true,
            label: 'Web',
            initialValue: '',
          ),
          const SizedBox(height: 10),


          const SizedBox(height: 15),
          const Text('Dirección'),

          const SizedBox(height: 15),
          const CustomCompanyField(
            isTopField: true,
            label: 'Dirección',
            initialValue: '',
          ),
          const SizedBox(height: 10),

          const CustomCompanyField(
            isTopField: true,
            label: 'Detalle de la dirección',
            initialValue: '',
          ),
          const SizedBox(height: 10),

          const CustomCompanyField(
            label: 'Población',
            initialValue: '',
          ),
          const SizedBox(height: 10),

          const CustomCompanyField(
            label: 'Prov. / Reg.',
            initialValue: '',
          ),
          const SizedBox(height: 10),

          const CustomCompanyField(
            label: 'Codigo Postal',
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

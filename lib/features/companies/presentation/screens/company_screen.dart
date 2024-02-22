import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyScreen extends ConsumerWidget {
  final String id;

  const CompanyScreen({super.key, required this.id});

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empresa creada correctamente.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyProvider(id));

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
        body: companyState.isLoading
            ? const FullScreenLoader()
            : _CompanyView(company: companyState.company!),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if ( companyState.company == null ) return;
    
            ref.read(
              companyFormProvider(companyState.company!).notifier
            ).onFormSubmit()
              .then((value) {
                if ( !value ) return;
                showSnackbar(context);
              });
    
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}

class _CompanyView extends ConsumerWidget {
  final Company company;

  const _CompanyView({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: [
        SizedBox(height: 10),
        _CompanyInformation(company: company),
      ],
    );
  }
}

class _CompanyInformation extends ConsumerWidget {
  final Company company;

  const _CompanyInformation({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> tags = ['Responsable 1', 'Responsable 2', 'Responsable 3'];

    List<DropdownOption> _optionsTipoCliente = [
      DropdownOption('01', 'Proveedor'),
      DropdownOption('02', 'Distribuidor'),
      DropdownOption('03', 'Prospecto'),
      DropdownOption('04', 'Cliente'),
    ];

    List<DropdownOption> _optionsEstado = [
      DropdownOption('A', 'ACTIVO'),
      DropdownOption('B', 'NO CLIENTE'),
    ];

    List<DropdownOption> _optionsCalificacion = [
      DropdownOption('A', 'A'),
      DropdownOption('B', 'B'),
      DropdownOption('C', 'C'),
      DropdownOption('D', 'D'),
    ];

    final companyForm = ref.watch(companyFormProvider(company));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generales'),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Nombre de la empresa *',
            initialValue: companyForm.razon.value,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onRazonChanged,
            errorMessage: companyForm.razon.errorMessage,
          ),
          const SizedBox(height: 10),
          CustomCompanyField(
            label: 'RUC *',
            initialValue:
                companyForm.ruc.value == 'new' ? '' : companyForm.ruc.value,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onRucChanged,
            errorMessage: companyForm.ruc.errorMessage,
          ),
          const SizedBox(height: 10),


          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Tipo:',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 200,
                  child: DropdownButton<String>(
                    // Valor seleccionado
                    value: companyForm.tipoCliente,
                    onChanged: (String? newValue) {
                      ref
                          .read(companyFormProvider(company).notifier)
                          .onTipoChanged(newValue!);
                    },
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    // Mapeo de las opciones a elementos de menú desplegable
                    items: _optionsTipoCliente.map((option) {
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
                const Text('Estado:',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 180, // Ancho específico para el DropdownButton
                  child: DropdownButton<String>(
                    // Valor seleccionado
                    value: companyForm.estado,
                    onChanged: (String? newValue) {
                      ref
                          .read(companyFormProvider(company).notifier)
                          .onEstadoChanged(newValue!);
                    },
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    // Mapeo de las opciones a elementos de menú desplegable
                    items: _optionsEstado.map((option) {
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
                const Text('Calificación:',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 100, // Ancho específico para el DropdownButton
                  child: DropdownButton<String>(
                    // Valor seleccionado
                    value: companyForm.calificacion,
                    onChanged: (String? newValue) {
                      ref
                          .read(companyFormProvider(company).notifier)
                          .onEstadoChanged(newValue!);
                    },
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    // Mapeo de las opciones a elementos de menú desplegable
                    items: _optionsCalificacion.map((option) {
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
                value: companyForm.visibleTodos == '1' ? true : false,
                onChanged: (bool? newValue) {
                      ref.read(companyFormProvider(company).notifier)
                          .onVisibleTodosChanged(newValue! ? '1' : '0');
                  
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomCompanyField(
            maxLines: 2,
            label: 'Comentarios',
            keyboardType: TextInputType.multiline,
            initialValue: companyForm.seguimientoComentario,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onComentarioChanged,
          ),
          const SizedBox(height: 20),
          CustomCompanyField(
            maxLines: 3,
            label: 'Recomendación',
            keyboardType: TextInputType.multiline,
            initialValue: companyForm.observaciones,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onRecomendacionChanged,
          ),
          const SizedBox(height: 15),
          const Text('Datos de contacto'),
          const SizedBox(height: 15),
          CustomCompanyField(
            isTopField: true,
            label: 'Email',
            initialValue: companyForm.email,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onEmailChanged,
          ),
          const SizedBox(height: 10),
          CustomCompanyField(
            isTopField: true,
            label: 'Web',
            initialValue: companyForm.website,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onWebChanged,
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 15),
          const Text('Dirección'),
          const SizedBox(height: 15),
          CustomCompanyField(
            isTopField: true,
            label: 'Dirección',
            initialValue: companyForm.direccion,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onDireccionChanged,
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
          CustomCompanyField(
            label: 'Codigo Postal',
            initialValue: companyForm.codigoPostal,
            onChanged:
                ref.read(companyFormProvider(company).notifier).onCodigoPostaChanged,
          ),
          const SizedBox(height: 100),
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

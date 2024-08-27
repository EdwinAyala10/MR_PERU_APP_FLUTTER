import 'package:crm_app/features/resource-detail/presentation/providers/resource_details_provider.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/widgets/find_filter_option_by_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterDetailRoutePlanner extends ConsumerStatefulWidget {
  String title;
  String type;

  FilterDetailRoutePlanner({super.key, required this.title, required this.type});

  @override
  _FilterDetailRoutePlannerState createState() => _FilterDetailRoutePlannerState();
}

class _FilterDetailRoutePlannerState extends ConsumerState<FilterDetailRoutePlanner>  {
  
  /*List<DropdownOption> optionsList = [
    //DropdownOption('', 'Cargando...')
  ];*/

  List<FilterOptionContainer> optionsMaster = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {

      final List<FilterOption> listFilters = ref.watch(routePlannerProvider).filters;

      switch (widget.type) {
        case 'HRTR_ID_HORARIO_TRABAJO':
          await ref.read(routePlannerProvider.notifier).loadFilterHorarioTrabajo().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
          break;

        case 'ESTADO':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('18').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
          break;

        case 'ULTIMAS_VISITAS':
          await ref.read(routePlannerProvider.notifier).loadFilterActivity().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'TIPOCLIENTE':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('02').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'ESTADO_CRM':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('03').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'CALIFICACION':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('04').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'ID_USUARIO_RESPONSABLE':
          await ref.read(routePlannerProvider.notifier).loadFilterResponsable().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'CODIGO_POSTAL':
          await ref.read(routePlannerProvider.notifier).loadFilterCodigoPostal().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'DISTRITO':
          await ref.read(routePlannerProvider.notifier).loadFilterDistrito().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'RUC':
          await ref.read(routePlannerProvider.notifier).loadFilterRuc().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'ID_RUBRO':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('16').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        case 'RAZON_COMERCIAL':
          await ref.read(routePlannerProvider.notifier).loadFiltecRazonComercial().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
            })
          });
        break;

        default:
      }
      
    });
  }

  List<FilterOptionContainer> getOptionProcess(List<DropdownOption> value, List<FilterOption> listFilters) {
    List<DropdownOption> optionsList = value;
    List<FilterOptionContainer> optionsM = [];

    
    final String? idFilter = findFilterOptionByType(listFilters, widget.type, 'id', '');
    
    optionsM = optionsList.asMap().entries.map((entry) {
      DropdownOption option = entry.value;
    
      final bool selectFilter = listFilters.isNotEmpty  
        ? idFilter == option.id: false;
    
      return FilterOptionContainer(
        id: option.id, 
        title: widget.title, 
        name: option.name, 
        onSelect: handleSelect, 
        isSelected: selectFilter,
        type: widget.type
      );
    }).toList();

    return optionsM;
    
  }

  void handleSelect(String id, String name, String type ,String title) {
    FilterOption anotherNewFilter = FilterOption(id: id, type: type, name: name, title: title);
  
    ref.read(routePlannerProvider.notifier).onSelectedFilter(anotherNewFilter);
  }
  
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight = screenHeight * 0.95; // 85% de la altura de la pantalla

    final List<FilterOption> listFilters = ref.watch(routePlannerProvider).filters;

    return Container(
      height: desiredHeight,
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                /*TextButton(
                  onPressed: () {
                    // Acción para aplicar filtros
                    Navigator.pop(context);
                  },
                  child: const Text('Hecho'),
                ),*/
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:  optionsMaster.isNotEmpty 
            ? ListView.builder(
              itemBuilder: ( context, index) {
                /*final options = [
                  FilterOption(id: '1', title: 'Sí'),
                  FilterOption(id: '2', title: 'No'),
                  FilterOption(id: '3', title: 'Todos'),
                ];*/

                return Column(
                  children: [
                    if (index > 0) const Divider(height: 1),
                    optionsMaster[index],
                  ],
                );
              },
              //separatorBuilder: (context, index) => const Divider(),
              itemCount: optionsMaster.length,
            ) : Container(
              padding: EdgeInsets.all(14),
              width: double.infinity,
              child: const Text('Sin opciones', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18), textAlign: TextAlign.center, )
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOptionContainer extends StatelessWidget {
  final String id;
  final String name;
  final String title;
  final String type;
  final bool isSelected;
  final Function(String,String,String, String) onSelect;

  FilterOptionContainer({
    super.key,
    required this.id, 
    required this.name,
    required this.title,
    required this.type,
    required this.isSelected,
    required this.onSelect,
    });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
         Navigator.pop(context);
         onSelect(id, name, type, title);
      },
      child: Container(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 16.0)),
            ],
          ),
        ),
      ),
    );
  }
}





import 'dart:async';

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
  bool? isSearch = false;

  FilterDetailRoutePlanner({super.key, required this.title, required this.type, this.isSearch});

  @override
  _FilterDetailRoutePlannerState createState() => _FilterDetailRoutePlannerState();
}

class _FilterDetailRoutePlannerState extends ConsumerState<FilterDetailRoutePlanner>  {
  
  /*List<DropdownOption> optionsList = [
    //DropdownOption('', 'Cargando...')
  ];*/

  List<FilterOptionContainer> optionsMaster = [];
  bool isLoading = false;
  String textSearch = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      loadingData();
    });
  }

  loadingData() async {
    setState(() {
        isLoading = true;
    });

    final List<FilterOption> listFilters = ref.watch(routePlannerProvider).filters;

      switch (widget.type) {
        case 'HRTR_ID_HORARIO_TRABAJO':
          await ref.read(routePlannerProvider.notifier).loadFilterHorarioTrabajo().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
          break;

        case 'ESTADO':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('18').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
          break;

        case 'ULTIMAS_VISITAS':
          await ref.read(routePlannerProvider.notifier).loadFilterActivity().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'TIPOCLIENTE':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('02').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'ESTADO_CRM':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('03').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'CALIFICACION':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('04').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'ID_USUARIO_RESPONSABLE':
          await ref.read(routePlannerProvider.notifier).loadFilterResponsable().then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'CODIGO_POSTAL':
          await ref.read(routePlannerProvider.notifier).loadFilterCodigoPostal(textSearch).then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'DISTRITO':
          await ref.read(routePlannerProvider.notifier).loadFilterDistrito(textSearch).then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'RUC':
          await ref.read(routePlannerProvider.notifier).loadFilterRuc(textSearch).then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'ID_RUBRO':
          await ref.read(resourceDetailsProvider.notifier).loadCatalogById('16').then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        case 'RAZON_COMERCIAL':
          await ref.read(routePlannerProvider.notifier).loadFiltecRazonComercial(textSearch).then((value) => {
            setState(() {
              optionsMaster = getOptionProcess(value, listFilters);
              isLoading = false;
            })
          });
        break;

        default:
      }
      
  }

  //Function(String)
  setTextSearch(String text) {
    setState(() {
      textSearch = text;
      // TODO: CARGAR LOAD SEARCH
      loadingData();
    });
  }

  deleteTextSearch() {
    setState(() {
      textSearch = '';
      loadingData();
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
        type: widget.type,
        subTitle: option.subTitle,
        secundary: option.secundary,
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

    //final List<FilterOption> listFilters = ref.watch(routePlannerProvider).filters;

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

          if (widget.isSearch == true) 
            _SearchComponent(placeholder: widget.title, onChange: setTextSearch, textSearch: textSearch, onDelete: deleteTextSearch,),

          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          if (!isLoading)
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
  final String? subTitle;
  final String? secundary;

  FilterOptionContainer({
    super.key,
    required this.id, 
    required this.name,
    required this.title,
    required this.type,
    required this.isSelected,
    required this.onSelect,
    this.subTitle,
    this.secundary
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500 )),
                  if (subTitle != null) Text(subTitle ?? '', style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400)),
                  if (secundary != null) Text(secundary ?? '', style: const TextStyle(fontSize: 15.0)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchComponent extends ConsumerStatefulWidget {
  String placeholder;
  Function(String) onChange;
  Function onDelete;
  String textSearch;

  _SearchComponent({super.key, required this.placeholder, required this.onChange, required this.onDelete, required this.textSearch});

  @override
  ConsumerState<_SearchComponent> createState() => __SearchComponentState();
}

class __SearchComponentState extends ConsumerState<_SearchComponent> {
   TextEditingController searchController = TextEditingController(
      //text: ref.read(routePlannerProvider).textSearch
    );


  @override
  Widget build(BuildContext context) {
    Timer? debounce;
    //TextEditingController searchController =
    //    TextEditingController(text: ref.read(companiesProvider).textSearch);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            style: const TextStyle(fontSize: 14.0),
            controller: searchController,
            onChanged: (String value) {
              if (debounce?.isActive ?? false) debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 500), () {
                //ref.read(companiesProvider.notifier).loadNextPage(value);
                widget.onChange(value);
                //ref.read(contactsProvider.notifier).onChangeTextSearch(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar ${widget.placeholder}...',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 18.0),
              hintStyle: const TextStyle(fontSize: 14.0, color: Colors.black38),
            ),
          ),
         
          // TODO: DESCOMENTAR ESTA LINEAS
          if (widget.textSearch != "")
            IconButton(
              onPressed: () {
                /*ref
                    .read(contactsProvider.notifier)
                    .onChangeNotIsActiveSearch();*/
                widget.onDelete();
                searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}



import 'dart:async';

import 'package:crm_app/config/config.dart';
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
  bool? isMulti = false;

  FilterDetailRoutePlanner({
    super.key,
    required this.title,
    required this.type,
    this.isSearch,
    this.isMulti,
  });

  @override
  ConsumerState<FilterDetailRoutePlanner> createState() =>
      _FilterDetailRoutePlannerState();
}

class _FilterDetailRoutePlannerState
    extends ConsumerState<FilterDetailRoutePlanner> {
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

    final List<FilterOption> listFilters =
        ref.watch(routePlannerProvider).filters;

    switch (widget.type) {
      case 'HRTR_ID_HORARIO_TRABAJO':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFilterHorarioTrabajo()
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'ESTADO':
        await ref
            .read(resourceDetailsProvider.notifier)
            .loadCatalogById(groupId: '18')
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'ULTIMAS_VISITAS':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFilterActivity()
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'TIPOCLIENTE':
        await ref
            .read(resourceDetailsProvider.notifier)
            .loadCatalogById(groupId: '02')
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'ESTADO_CRM':
        await ref
            .read(resourceDetailsProvider.notifier)
            .loadCatalogById(groupId: '03')
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'CALIFICACION':
        await ref
            .read(resourceDetailsProvider.notifier)
            .loadCatalogById(groupId: '04')
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'ID_USUARIO_RESPONSABLE':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFilterResponsable()
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'ID_TIPO_OPORTUNIDAD':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFilterTypeOpportunity()
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'CODIGO_POSTAL':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFilterCodigoPostal(textSearch)
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'DISTRITO':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFilterDistrito(textSearch)
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'RUC':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFilterRuc(textSearch)
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'ID_RUBRO':
        await ref
            .read(resourceDetailsProvider.notifier)
            .loadCatalogById(groupId: '16')
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
                    isLoading = false;
                  })
                });
        break;

      case 'RAZON_COMERCIAL':
        await ref
            .read(routePlannerProvider.notifier)
            .loadFiltecRazonComercial(textSearch)
            .then((value) => {
                  setState(() {
                    optionsMaster =
                        getOptionProcess(value, listFilters, widget.isMulti);
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

  List<FilterOptionContainer> getOptionProcess(List<DropdownOption> value,
      List<FilterOption> listFilters, bool? isMulti) {
    List<DropdownOption> optionsList = value;
    List<FilterOptionContainer> optionsM = [];

    final String? idFilter =
        findFilterOptionByType(listFilters, widget.type, 'id', '');

    print('aqui esta: ${idFilter}');

    optionsM = optionsList.asMap().entries.map((entry) {
      DropdownOption option = entry.value;

      print('ESTO QUES ES: ${option.id}');

      bool selectFilter = false;

      if (isMulti == true) {
        if (idFilter != "") {
          List<String> lists = idFilter!.split(',');
          if (lists.contains(option.id)) {
            selectFilter = true;
          }
        }
      } else {
        selectFilter = listFilters.isNotEmpty ? idFilter == option.id : false;
      }

      return FilterOptionContainer(
          id: option.id,
          title: widget.title,
          name: option.name,
          onSelect: handleSelect,
          isSelected: selectFilter,
          type: widget.type,
          subTitle: option.subTitle,
          secundary: option.secundary,
          isMulti: isMulti);
    }).toList();

    return optionsM;
  }

  void handleSelect(
      String id, String name, String type, String title, bool isMulti) {
    FilterOption anotherNewFilter =
        FilterOption(id: id, type: type, name: name, title: title);

    ref
        .read(routePlannerProvider.notifier)
        .onSelectedFilter(anotherNewFilter, isMulti);

    setState(() {
      print('optionsMaster: ${optionsMaster.length}');

      var optionsNew = [...optionsMaster];

      var indexdelete;

      print('imprimir.--------');
      for (var i = 0; i < optionsMaster.length; i++) {
        if (optionsMaster[i].id == id) {
          optionsNew[i] = FilterOptionContainer(
            id: optionsMaster[i].id,
            name: optionsMaster[i].name,
            title: optionsMaster[i].title,
            type: optionsMaster[i].type,
            isSelected: !optionsMaster[i].isSelected,
            onSelect: optionsMaster[i].onSelect,
            isMulti: optionsMaster[i].isMulti,
            key: optionsMaster[i].key,
            secundary: optionsMaster[i].secundary,
            subTitle: optionsMaster[i].subTitle,
          );
          //} else {
          //optionsNew.removeAt(i);
        }
      }
      print('imprimir end.--------');

      optionsMaster = optionsNew;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight =
        screenHeight * 0.95; // 85% de la altura de la pantalla

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
                /*if(widget.isMulti == true)
                  TextButton(
                    onPressed: () {
                      // Acción para aplicar filtros
                     // Navigator.pop(context);
                    },
                    child: const Text('Hecho'),
                  ),*/
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (widget.isSearch == true)
            _SearchComponent(
              placeholder: widget.title,
              onChange: setTextSearch,
              textSearch: textSearch,
              onDelete: deleteTextSearch,
            ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (!isLoading)
            Expanded(
              child: optionsMaster.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
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
                    )
                  : Container(
                      padding: const EdgeInsets.all(14),
                      width: double.infinity,
                      child: const Text(
                        'Sin opciones',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                        textAlign: TextAlign.center,
                      )),
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
  final Function(String, String, String, String, bool) onSelect;
  final String? subTitle;
  final String? secundary;
  final bool? isMulti;

  FilterOptionContainer(
      {super.key,
      required this.id,
      required this.name,
      required this.title,
      required this.type,
      required this.isSelected,
      required this.onSelect,
      this.subTitle,
      this.secundary,
      this.isMulti});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isMulti == true) {
          if (id != '') {
            onSelect(id, name, type, title, true);
          }
        } else {
          Navigator.pop(context);
          onSelect(id, name, type, title, false);
        }
      },
      child: Container(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isMulti == true && id != "")
                        Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank_outlined,
                            size: 26,
                            color: primaryColor),
                      if (isMulti == true && id != "")
                        const SizedBox(
                          width: 10,
                        ),
                      Column(
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 17.0, fontWeight: FontWeight.w500)),
                          if (subTitle != null)
                            Text(subTitle ?? '',
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400)),
                          if (secundary != null)
                            Text(secundary ?? '',
                                style: const TextStyle(fontSize: 15.0)),
                        ],
                      )
                    ],
                  ),
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

  _SearchComponent(
      {super.key,
      required this.placeholder,
      required this.onChange,
      required this.onDelete,
      required this.textSearch});

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

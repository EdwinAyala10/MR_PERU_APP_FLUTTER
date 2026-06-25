import 'dart:async';

import 'package:crm_app/features/companies/presentation/providers/companies_provider.dart';

import 'package:crm_app/features/route-planner/domain/entities/filter_option.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/widgets/find_filter_option_by_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/config.dart';
import '../../../../config/theme/app_theme.dart';

class FilterDetailCompanies extends ConsumerStatefulWidget {
  final String title;
  final String type;
  final bool? isSearch;
  final bool? isMulti;

  const FilterDetailCompanies({
    super.key,
    required this.title,
    required this.type,
    this.isSearch = false,
    this.isMulti = false,
  });

  @override
  ConsumerState<FilterDetailCompanies> createState() =>
      _FilterDetailCompaniesState();
}

class _FilterDetailCompaniesState extends ConsumerState<FilterDetailCompanies> {
  List<FilterOptionContainer> optionsMaster = [];
  bool isLoading = false;
  String textSearch = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadingData();
    });
  }

  loadingData() async {
    setState(() {
      isLoading = true;
    });

    final List<FilterOption> listFilters = ref.read(companiesProvider).filters;

    final notifier = ref.read(companiesProvider.notifier);

    switch (widget.type) {
      case 'ID_RUBRO':
      case 'CALIFICACION':
      case 'ID_USUARIO_RESPONSABLE':
      case 'ACTIVIDAD':
      case 'ESTADO':
      case 'DISTANCIA':
        // Usar getFilterOptions que primero busca en cache
        await notifier.getFilterOptions(widget.type).then((value) {
          setState(() {
            optionsMaster =
                getOptionProcess(value, listFilters, widget.isMulti);
            isLoading = false;
          });
        });
        break;

      case 'DEPARTAMENTO':
        // Usar cache con filtrado del lado del cliente
        await notifier
            .getFilterOptions(widget.type, searchText: textSearch)
            .then((value) {
          setState(() {
            optionsMaster =
                getOptionProcess(value, listFilters, widget.isMulti);
            isLoading = false;
          });
        });
        break;

      case 'PROVINCIA':
        // Obtener provincias del departamento seleccionado (con cache)
        final selectedDeptId = listFilters
            .firstWhere((f) => f.type == 'DEPARTAMENTO',
                orElse: () =>
                    FilterOption(id: '', name: '', type: '', title: ''))
            .id;

        await notifier
            .getProvinciaOptions(selectedDeptId, textSearch)
            .then((value) {
          setState(() {
            optionsMaster =
                getOptionProcess(value, listFilters, widget.isMulti);
            isLoading = false;
          });
        });
        break;

      case 'DISTRITO':
        // Obtener distritos de la provincia seleccionada (con cache)
        final selectedProvId = listFilters
            .firstWhere((f) => f.type == 'PROVINCIA',
                orElse: () =>
                    FilterOption(id: '', name: '', type: '', title: ''))
            .id;

        await notifier
            .getDistritoOptions(selectedProvId, textSearch)
            .then((value) {
          setState(() {
            optionsMaster =
                getOptionProcess(value, listFilters, widget.isMulti);
            isLoading = false;
          });
        });
        break;

      default:
        setState(() {
          isLoading = false;
        });
    }
  }

  setTextSearch(String text) {
    setState(() {
      textSearch = text;
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

    String? idFilter;

    idFilter = findFilterOptionByType(listFilters, widget.type, 'id', '');

    optionsM = optionsList.asMap().entries.map((entry) {
      DropdownOption option = entry.value;

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
          key: ValueKey(option.id),
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
    if (name.contains('Selecciona')) {
      ref.read(companiesProvider.notifier).onDeleteFilterByType(type);
    } else {
      FilterOption newFilter =
          FilterOption(id: id, type: type, name: name, title: title);

      ref.read(companiesProvider.notifier).onSelectedFilter(newFilter, isMulti);
    }

    setState(() {
      final listFilters = ref.read(companiesProvider).filters;

      String? updatedIdFilter;
      updatedIdFilter = findFilterOptionByType(listFilters, type, 'id', '');

      var optionsNew = [...optionsMaster];
      for (var i = 0; i < optionsMaster.length; i++) {
        bool isSelected = false;
        if (isMulti == true) {
          if (updatedIdFilter != "") {
            List<String> lists = updatedIdFilter!.split(',');
            if (lists.contains(optionsMaster[i].id)) {
              isSelected = true;
            }
          }
        } else {
          isSelected = updatedIdFilter == optionsMaster[i].id;
        }

        optionsNew[i] = FilterOptionContainer(
          key: ValueKey(optionsMaster[i].id),
          id: optionsMaster[i].id,
          name: optionsMaster[i].name,
          title: optionsMaster[i].title,
          type: optionsMaster[i].type,
          isSelected: isSelected,
          onSelect: optionsMaster[i].onSelect,
          isMulti: optionsMaster[i].isMulti,
          secundary: optionsMaster[i].secundary,
          subTitle: optionsMaster[i].subTitle,
        );
      }
      optionsMaster = optionsNew;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight = screenHeight * 0.95;

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
                        return Column(
                          children: [
                            if (index > 0) const Divider(height: 1),
                            optionsMaster[index],
                          ],
                        );
                      },
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

  const FilterOptionContainer(
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
              Expanded(
                child: Column(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w500)),
                              if (subTitle != null)
                                Text(subTitle ?? '',
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400)),
                              if (secundary != null)
                                Text(secundary ?? '',
                                    style: const TextStyle(fontSize: 15.0)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchComponent extends ConsumerStatefulWidget {
  final String placeholder;
  final Function(String) onChange;
  final Function onDelete;
  final String textSearch;

  const _SearchComponent(
      {super.key,
      required this.placeholder,
      required this.onChange,
      required this.onDelete,
      required this.textSearch});

  @override
  ConsumerState<_SearchComponent> createState() => __SearchComponentState();
}

class __SearchComponentState extends ConsumerState<_SearchComponent> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Timer? debounce;

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
                widget.onChange(value);
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
          if (widget.textSearch != "")
            IconButton(
              onPressed: () {
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

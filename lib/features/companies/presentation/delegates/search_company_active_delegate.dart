import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchCompaniesCallback = Future<List<Company>> Function(String dni, String query);
typedef ResetSearchQueryCallback = void Function();

class SearchCompanyDelegate extends SearchDelegate<Company?> {
  final SearchCompaniesCallback searchCompanies;
  final ResetSearchQueryCallback resetSearchQuery;
  List<Company> initialCompanies;

  late StreamController<List<Company>> debouncedCompanies;
  late StreamController<bool> isLoadingStream;

  Timer? _debounceTimer;
  String dni;

  SearchCompanyDelegate({
    required this.searchCompanies,
    required this.initialCompanies,
    required this.resetSearchQuery,
    required this.dni,
  }) : super(
          searchFieldLabel: 'Buscar empresas',
          searchFieldStyle: const TextStyle(color: Colors.black45, fontSize: 16),
        ) {
    _initializeStreams();
  }

  void _initializeStreams() {
    debouncedCompanies = StreamController.broadcast();
    isLoadingStream = StreamController.broadcast();
  }

  void clearStreams() {
    debouncedCompanies.close();
    isLoadingStream.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final companies = await searchCompanies(dni, query);
      initialCompanies = companies;
      debouncedCompanies.add(companies);
      isLoadingStream.add(false);
    });
  }

  /*Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialCompanies,
      stream: debouncedCompanies.stream,
      builder: (context, snapshot) {
        final companies = snapshot.data ?? [];

        return ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: companies.length,
          itemBuilder: (context, index) => _CompanyItem(
            company: companies[index],
            onCompanySelected: (context, company) {
              clearStreams();
              close(context, company);
            },
          ),
        );
      },
    );
  }*/
  Widget buildResultsAndSuggestions() {
    return FutureBuilder<List<Company>>(
      future: searchCompanies(dni, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar los datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No existen registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else {
          final companies = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemCount: companies.length,
            itemBuilder: (context, index) => _CompanyItem(
              company: companies[index],
              onCompanySelected: (context, user) {
                clearStreams();
                close(context, user);
              },
            ),
          );
        }
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              spins: 10,
              infinite: true,
              child: IconButton(
                onPressed: () => query = '',
                icon: const Icon(Icons.refresh_rounded),
              ),
            );
          }

          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
              onPressed: () => query = '',
              icon: const Icon(Icons.clear),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        resetSearchQuery();
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return buildResultsAndSuggestions();
  }

  @override
  void close(BuildContext context, Company? result) {
    query = '';
    clearStreams();
    resetSearchQuery();
    super.close(context, result);
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    clearStreams();
    _initializeStreams();
    _onQueryChanged(query);
  }
}

class _CompanyItem extends StatelessWidget {
  final Company company;
  final Function onCompanySelected;

  const _CompanyItem({required this.company, required this.onCompanySelected});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final canSelect = company.estadoVisible == '1';
    final razonComercial = company.razonComercial?.trim() ?? '';
    final showRazonComercial =
        razonComercial.isNotEmpty && razonComercial != company.razon.trim();
    final textColor = canSelect ? Colors.black87 : Colors.black38;
    final subtitleColor = canSelect ? Colors.black54 : Colors.black38;

    return GestureDetector(
      onTap: () {
        if (canSelect) {
          onCompanySelected(context, company);
          return;
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se puede seleccionar esta empresa, Usted no es responsable.',
            ),
          ),
        );
      },
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: size.width * 0.16,
                child: Icon(
                  Icons.blinds_outlined,
                  color: canSelect ? Colors.black54 : Colors.black26,
                ),
              ),

              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.razon,
                      style: textStyles.titleMedium?.copyWith(color: textColor),
                    ),
                    if (showRazonComercial)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          razonComercial,
                          style: textStyles.bodyMedium?.copyWith(
                            color: canSelect
                                ? Colors.blueGrey.shade600
                                : Colors.black38,
                          ),
                        ),
                      ),
                    if (!canSelect)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Solo lectura',
                          style: textStyles.bodySmall?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Text(
                          'RUC: ',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          company.ruc,
                          style: TextStyle(
                            color: subtitleColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

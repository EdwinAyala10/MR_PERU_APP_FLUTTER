import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchCompanyLocalesCallback = Future<List<CompanyLocal>> Function(String ruc, String query);
typedef ResetSearchQueryCallback = void Function();

class SearchCompanyLocalDelegate extends SearchDelegate<CompanyLocal?> {
  final SearchCompanyLocalesCallback searchCompanyLocales;
  final ResetSearchQueryCallback resetSearchQuery;
  List<CompanyLocal> initialCompanyLocales;
  String ruc;

  late StreamController<List<CompanyLocal>> debouncedCompanyLocales;
  late StreamController<bool> isLoadingStream;

  Timer? _debounceTimer;

  SearchCompanyLocalDelegate({
    required this.searchCompanyLocales,
    required this.initialCompanyLocales,
    required this.resetSearchQuery,
    required this.ruc,
  }) : super(
          searchFieldLabel: 'Buscar locales',
          searchFieldStyle: const TextStyle(color: Colors.black45, fontSize: 16),
        ) {
    _initializeStreams();
  }

  void _initializeStreams() {
    debouncedCompanyLocales = StreamController.broadcast();
    isLoadingStream = StreamController.broadcast();
  }

  void clearStreams() {
    debouncedCompanyLocales.close();
    isLoadingStream.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final companyLocales = await searchCompanyLocales(ruc, query);
      initialCompanyLocales = companyLocales;
      debouncedCompanyLocales.add(companyLocales);
      isLoadingStream.add(false);
    });
  }

  /*Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialCompanyLocales,
      stream: debouncedCompanyLocales.stream,
      builder: (context, snapshot) {
        final companyLocales = snapshot.data ?? [];

        return ListView.builder(
          itemCount: companyLocales.length,
          itemBuilder: (context, index) => _CompanyLocalItem(
            companyLocal: companyLocales[index],
            onCompanyLocalSelected: (context, companyLocal) {
              clearStreams();
              close(context, companyLocal);
            },
          ),
        );
      },
    );
  }*/

  Widget buildResultsAndSuggestions() {
    return FutureBuilder<List<CompanyLocal>>(
      future: searchCompanyLocales(ruc, query),
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
            itemBuilder: (context, index) => _CompanyLocalItem(
              companyLocal: companies[index],
              onCompanyLocalSelected: (context, user) {
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
  void close(BuildContext context, CompanyLocal? result) {
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

class _CompanyLocalItem extends StatelessWidget {
  final CompanyLocal companyLocal;
  final Function onCompanyLocalSelected;

  const _CompanyLocalItem({required this.companyLocal, required this.onCompanyLocalSelected});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onCompanyLocalSelected(context, companyLocal);
      },
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: size.width * 0.2,
                child: const Icon(Icons.blinds_outlined),
              ),

              const SizedBox(width: 10),

              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyLocal.localNombre == "" ? '[LOCAL SIN NOMBRE]' : companyLocal.localNombre,
                      style: textStyles.titleMedium?.copyWith(
                        color: companyLocal.localNombre == "" ? Colors.black45 : Colors.black
                      ), 
                      overflow: TextOverflow.ellipsis
                    ),
                    Text(
                      companyLocal.localTipoDescripcion ?? ''
                      , overflow: TextOverflow.ellipsis
                    ),
                    Text(companyLocal.localDireccion ?? '', overflow: TextOverflow.ellipsis),
                    Text('${companyLocal.departamento} - ${companyLocal.provincia} - ${companyLocal.distrito}', overflow: TextOverflow.ellipsis),
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

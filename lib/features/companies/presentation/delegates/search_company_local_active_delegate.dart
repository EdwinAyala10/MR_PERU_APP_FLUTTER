import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchCompanyLocalesCallback = Future<List<CompanyLocal>> Function(String ruc,
    String query);

class SearchCompanyLocalDelegate extends SearchDelegate<CompanyLocal?> {
  final SearchCompanyLocalesCallback searchCompanyLocales;
  List<CompanyLocal> initialCompanyLocales;
  String ruc;

  StreamController<List<CompanyLocal>> debouncedCompanyLocales =
      StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  SearchCompanyLocalDelegate({
    required this.searchCompanyLocales,
    required this.initialCompanyLocales,
    required this.ruc,
  }) : super(
          searchFieldLabel: 'Buscar locales',
          // textInputAction: TextInputAction.done
        );

  void clearStreams() {
    debouncedCompanyLocales.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // if ( query.isEmpty ) {
      //   debouncedCompanies.add([]);
      //   return;
      // }

      final companyLocales = await searchCompanyLocales(ruc, query);
      initialCompanyLocales = companyLocales;
      debouncedCompanyLocales.add(companyLocales);
      isLoadingStream.add(false);
    });
  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialCompanyLocales,
      stream: debouncedCompanyLocales.stream,
      builder: (context, snapshot) {
        final companyLocales = snapshot.data ?? [];

        return ListView.builder(
          itemCount: companyLocales.length,
          itemBuilder: (context, index) => _CompanyLocalItem(
            companyLocal: companyLocales[index],
            onCompanyLocalSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            },
          ),
        );
      },
    );
  }

  // @override
  // String get searchFieldLabel => 'Buscar empresa';

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
                  icon: const Icon(Icons.refresh_rounded)),
            );
          }

          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
                onPressed: () => query = '', icon: const Icon(Icons.clear)),
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
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded));
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
}

class _CompanyLocalItem extends StatelessWidget {
  final CompanyLocal companyLocal;
  final Function onCompanyLocalSelected;

  const _CompanyLocalItem(
      {required this.companyLocal, required this.onCompanyLocalSelected});

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

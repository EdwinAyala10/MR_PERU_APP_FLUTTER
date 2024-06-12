import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchCompaniesCallback = Future<List<Company>> Function(
    String dni, String query);

class SearchCompanyDelegate extends SearchDelegate<Company?> {
  final SearchCompaniesCallback searchCompanies;
  List<Company> initialCompanies;

  StreamController<List<Company>> debouncedCompanies =
      StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  String dni;

  SearchCompanyDelegate({
    required this.searchCompanies,
    required this.initialCompanies,
    required this.dni,
  }) : super(
          searchFieldLabel: 'Buscar empresas',
          searchFieldStyle: const TextStyle(color: Colors.black45, fontSize: 16),
          // textInputAction: TextInputAction.done
        );

  void clearStreams() {
    debouncedCompanies.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // if ( query.isEmpty ) {
      //   debouncedCompanies.add([]);
      //   return;
      // }

      final companies = await searchCompanies(dni, query);
      initialCompanies = companies;
      debouncedCompanies.add(companies);
      isLoadingStream.add(false);
    });
  }

  Widget buildResultsAndSuggestions() {
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
            onCompanySelected: (context, movie) {
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

class _CompanyItem extends StatelessWidget {
  final Company company;
  final Function onCompanySelected;

  const _CompanyItem({required this.company, required this.onCompanySelected});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onCompanySelected(context, company);
      },
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: size.width * 0.16,
                child: const Icon(Icons.blinds_outlined),
              ),

              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.razon,
                      style: textStyles.titleMedium,
                    ),
                    Row(
                      children: [
                        const Text('RUC: ', style: TextStyle( color: Colors.black87, fontWeight: FontWeight.w600 )),
                        Text(company.ruc, style: const TextStyle( color: Colors.black87, fontWeight: FontWeight.w400 ),),
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

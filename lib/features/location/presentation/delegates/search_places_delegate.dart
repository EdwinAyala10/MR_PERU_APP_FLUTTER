import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchPlacesCallback = Future<List<Place>> Function(String query);

class SearchPlaceDelegate extends SearchDelegate<Place?> {
  final SearchPlacesCallback searchPlaces;
  List<Place> initialPlaces;

  StreamController<List<Place>> debouncedPlaces =
      StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  SearchPlaceDelegate({
    required this.searchPlaces,
    required this.initialPlaces,
  }) : super(
          searchFieldLabel: 'Buscar dirección',
          // textInputAction: TextInputAction.done
        );

  void clearStreams() {
    debouncedPlaces.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // if ( query.isEmpty ) {
      //   debouncedCompanies.add([]);
      //   return;
      // }

      final places = await searchPlaces(query);

      initialPlaces = places;
      debouncedPlaces.add(places);
      isLoadingStream.add(false);
    });
  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialPlaces,
      stream: debouncedPlaces.stream,
      builder: (context, snapshot) {
        final places = snapshot.data ?? [];

        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) => _PlaceItem(
            place: places[index],
            onPlaceSelected: (context, movie) {
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

class _PlaceItem extends StatelessWidget {
  final Place place;
  final Function onPlaceSelected;

  const _PlaceItem(
      {required this.place, required this.onPlaceSelected});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onPlaceSelected(context, place);
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
                      place.displayName?.text ?? '',
                      style: textStyles.titleSmall,
                    ),
                    Text(
                      place.shortFormattedAddress,
                      style: const TextStyle(
                        color: Colors.black45
                      ),
                    ),
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

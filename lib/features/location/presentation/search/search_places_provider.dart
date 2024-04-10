import 'package:crm_app/features/location/domain/domain.dart';
import 'package:crm_app/features/location/presentation/providers/places_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryPlacesProvider = StateProvider<String>((ref) => '');

final searchedPlacesProvider = StateNotifierProvider<SearchedPlacesNotifier, List<Place>>((ref) {

  final placeRepository = ref.read( placesRepositoryProvider );

  return SearchedPlacesNotifier(
    searchPlaces: placeRepository.getResultsByQuery, 
    ref: ref
  );
});


typedef SearchPlacesCallback = Future<List<Place>> Function(String query);

class SearchedPlacesNotifier extends StateNotifier<List<Place>> {

  final SearchPlacesCallback searchPlaces;
  final Ref ref;

  SearchedPlacesNotifier({
    required this.searchPlaces,
    required this.ref,
  }): super([]);


  Future<List<Place>> searchPlacesByQuery(String query ) async{
    
    final List<Place> places = await searchPlaces(query);
    ref.read(searchQueryPlacesProvider.notifier).update((state) => query);

    state = places;
    return places;
  }

}







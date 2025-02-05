import '../domain.dart';

abstract class PlacesDatasource {

  Future<List<Place>> getResultsByQuery(String query);
  Future<Place> getDetailByPlaceId(String placeId);
  Future<String> getSearchPlaceIdByCoors(String coors);
  Future<DistanceMatrix> getDistanceAndDuration({double originLat, double originLng, double destLat, double destLng});

}


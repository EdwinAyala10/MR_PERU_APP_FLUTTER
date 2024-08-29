
import '../../domain/domain.dart';

class PlacesRepositoryImpl extends PlacesRepository {

  final PlacesDatasource datasource;

  PlacesRepositoryImpl(this.datasource);
  
  @override
  Future<Place> getDetailByPlaceId(String placeId) {
    return datasource.getDetailByPlaceId(placeId);
  }
  
  @override
  Future<List<Place>> getResultsByQuery(String query) {
    return datasource.getResultsByQuery(query);
  }
  
  @override
  Future<String> getSearchPlaceIdByCoors(String coors) {
    return datasource.getSearchPlaceIdByCoors(coors);
  }

  @override
  Future<DistanceMatrix> getDistanceAndDuration({ 
    double originLat = 0, 
    double originLng = 0, 
    double destLat = 0, 
    double destLng = 0 }) {
    return datasource.getDistanceAndDuration(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng
    );
  }

}
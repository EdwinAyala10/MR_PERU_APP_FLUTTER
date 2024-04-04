
import 'package:crm_app/features/location/domain/domain.dart';

class PlaceRepositoryImpl extends PlaceRepository {

  final PlaceDatasource datasource;

  PlaceRepositoryImpl(this.datasource);
  
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



}
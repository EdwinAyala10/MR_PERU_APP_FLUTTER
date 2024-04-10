
import 'package:crm_app/features/location/domain/domain.dart';

abstract class PlacesRepository {
  
  Future<List<Place>> getResultsByQuery(String query);
  Future<Place> getDetailByPlaceId(String placeId);
  Future<String> getSearchPlaceIdByCoors(String coors);

}


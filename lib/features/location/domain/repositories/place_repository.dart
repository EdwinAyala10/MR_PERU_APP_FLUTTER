
import 'package:crm_app/features/location/domain/models/places_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class PlaceRepository {
  
  Future<List<Feature>> getResultsByQuery(LatLng proximity, String query);
  Future<Feature> getInformationByCoors(LatLng coors);

}


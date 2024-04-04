
import 'package:crm_app/features/location/domain/domain.dart';
import 'package:crm_app/features/location/domain/models/places_models.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class PlaceRepositoryImpl extends PlaceRepository {

  final PlaceDatasource datasource;

  PlaceRepositoryImpl(this.datasource);

  @override
  Future<Feature> getInformationByCoors(LatLng coors) {
    // TODO: implement getInformationByCoors
    throw UnimplementedError();
  }

  @override
  Future<List<Feature>> getResultsByQuery(LatLng proximity, String query) {
    // TODO: implement getResultsByQuery
    throw UnimplementedError();
  }


}
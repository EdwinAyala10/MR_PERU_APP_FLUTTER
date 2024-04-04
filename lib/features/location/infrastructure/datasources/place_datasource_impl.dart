import 'package:crm_app/features/location/domain/domain.dart';
import 'package:crm_app/features/location/domain/models/places_models.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/opportunity_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class PlaceDatasourceImpl extends PlaceDatasource {
  late final Dio dio;

  PlaceDatasourceImpl()
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrlPlace,
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': Environment.apiKeyGooglePlace,
              'X-Goog-FieldMask': 'places.name,places.id,places.formattedAddress,places.addressComponents,places.location'
            }));


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

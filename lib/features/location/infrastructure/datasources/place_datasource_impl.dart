import 'package:crm_app/features/location/domain/domain.dart';
import 'package:crm_app/features/location/domain/entities/geocode_response.dart';
import 'package:crm_app/features/location/infrastructure/mappers/geocode_response_mapper.dart';
import 'package:crm_app/features/location/infrastructure/mappers/place_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';

class PlaceDatasourceImpl extends PlaceDatasource {
  @override
  Future<Place> getDetailByPlaceId(String placeId) async {
    final dio = Dio();

    final String url = 'https://places.googleapis.com/v1/places/${placeId}';

    final response = await dio.get(url,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': Environment.apiKeyGooglePlace,
          'X-Goog-FieldMask':
              'name,id,formattedAddress,addressComponents,location'
        }));

    final Place place = PlaceMapper.jsonToEntity(response.data);

    return place;
  }

  @override
  Future<List<Place>> getResultsByQuery(String query) async {
    final dio = Dio();

    const String url = 'https://places.googleapis.com/v1/places:searchText';

    final data = {
      "textQuery": query,
      "regionCode": "PE",
    };

    final response = await dio.post(url,
        data: data,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': Environment.apiKeyGooglePlace,
          'X-Goog-FieldMask':
              'places.name,places.id,places.formattedAddress,places.addressComponents,places.location'
        }));

    final List<Place> places = [];
    for (final place in response.data ?? []) {
      places.add(PlaceMapper.jsonToEntity(place));
    }

    return places;
  }

  @override
  Future<String> getSearchPlaceIdByCoors(String coors) async {
    final dio = Dio();

    const String url = 'https://maps.googleapis.com/maps/api/geocode/json';

    final params = {
      "latlng": coors,
      "key": Environment.apiKeyGoogleGeocode,
      "language": "es",
      "region": "PE",
      "result_type": "street_address",
    };

    final response = await dio.get(url, queryParameters: params);

    final GeocodeResponse geocodeResponse =
        GeocodeResponseMapper.jsonToEntity(response.data);

    if (geocodeResponse.results.isNotEmpty) {
      GeocodeResult geocodeResult = geocodeResponse.results[0];
      String placeId = geocodeResult.placeId;
      return placeId;
    }

    return "";
  }
}

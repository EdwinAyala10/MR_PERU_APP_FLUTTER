import '../../domain/entities/geocode_response.dart';

class GeocodeResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => GeocodeResponse(
    plusCode: PlusCode.fromJson(json["plus_code"]),
    results: List<GeocodeResult>.from(json["results"].map((x) => GeocodeResult.fromJson(x))),
    status: json["status"],
  );

}

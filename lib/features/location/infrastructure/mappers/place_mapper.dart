import 'package:crm_app/features/location/domain/domain.dart';

class PlaceMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Place(
    name: json['name'],
    id: json['id'],
    formattedAddress: json['formattedAddress'],
    addressComponents: List<AddressComponent>.from(json["addressComponents"].map((x) => AddressComponent.fromJson(x))),
    location: Location.fromJson(json["location"]),
  );

}

import 'dart:convert';

Place placeFromJson(String str) => Place.fromJson(json.decode(str));

String placeToJson(Place data) => json.encode(data.toJson());

class DisplayName {
  String? text;
  String? languageCode;

  DisplayName({this.text, this.languageCode});

  factory DisplayName.fromJson(Map<String, dynamic> json) => DisplayName(
        text: json["text"] ?? '',
        languageCode: json["languageCode"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "languageCode": languageCode,
      };
}

class Place {
  String name;
  String id;
  String formattedAddress;
  DisplayName? displayName;
  String shortFormattedAddress;
  List<AddressComponent> addressComponents;
  Location location;

  Place({
    required this.name,
    required this.id,
    required this.formattedAddress,
    required this.shortFormattedAddress,
    required this.addressComponents,
    required this.location,
    this.displayName,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        name: json["name"],
        id: json["id"],
        formattedAddress: json["formattedAddress"],
        shortFormattedAddress: json["shortFormattedAddress"],
        addressComponents: List<AddressComponent>.from(
            json["addressComponents"].map((x) => AddressComponent.fromJson(x))),
        location: Location.fromJson(json["location"]),
        displayName: DisplayName.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "formattedAddress": formattedAddress,
        "shortFormattedAddress": shortFormattedAddress,
        "addressComponents":
            List<dynamic>.from(addressComponents.map((x) => x.toJson())),
        "location": location.toJson(),
      };
}

class AddressComponent {
  String longText;
  String shortText;
  List<String> types;
  String languageCode;

  AddressComponent({
    required this.longText,
    required this.shortText,
    required this.types,
    required this.languageCode,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      AddressComponent(
        longText: json["longText"] ?? '',
        shortText: json["shortText"] ?? '',
        types: List<String>.from(json["types"].map((x) => x)),
        languageCode: json["languageCode"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "longText": longText,
        "shortText": shortText,
        "types": List<dynamic>.from(types.map((x) => x)),
        "languageCode": languageCode,
      };
}

class Location {
  double latitude;
  double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

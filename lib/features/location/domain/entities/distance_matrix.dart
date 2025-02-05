class DistanceMatrix {
  final String distanceText;
  final int distanceValue;
  final String durationText;
  final int durationValue;

  DistanceMatrix({
    required this.distanceText,
    required this.distanceValue,
    required this.durationText,
    required this.durationValue,
  });

  // Factory constructor to create an instance from a JSON map
  factory DistanceMatrix.fromJson(Map<String, dynamic> json) {
    final element = json['rows'][0]['elements'][0];
    return DistanceMatrix(
      distanceText: element['distance']['text'],
      distanceValue: element['distance']['value'],
      durationText: element['duration']['text'],
      durationValue: element['duration']['value'],
    );
  }
}
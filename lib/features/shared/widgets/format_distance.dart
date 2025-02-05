String formatDistance(double metros) {
  if (metros < 1000) {
    return '${metros.toStringAsFixed(2)} m';
  } else {
    double kilometros = metros / 1000;
    return '${kilometros.toStringAsFixed(2)} km';
  }
}

String formatDistanceV2(int distanceInMeters) {
  if (distanceInMeters >= 1000) {
    final distanceInKilometers = distanceInMeters / 1000;
    return '${distanceInKilometers.toStringAsFixed(1)} km';
  } else {
    return '$distanceInMeters m';
  }
}
String formatDistance(double metros) {
  if (metros < 1000) {
    return '${metros.toStringAsFixed(2)} m';
  } else {
    double kilometros = metros / 1000;
    return '${kilometros.toStringAsFixed(2)} km';
  }
}

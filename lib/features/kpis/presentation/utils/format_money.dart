/// Formatea un valor monetario a formato con K (miles)
/// Ejemplos:
/// - 1000 → 1.0K
/// - 9500 → 9.5K
/// - 50000 → 50K
/// - 101000 → 101K
String formatMoneyToK(String amount) {
  try {
    final double value = double.parse(amount);
    final double thousands = value / 1000;
    
    // Si es un número entero (ej: 50.0, 101.0), no mostrar decimales
    if (thousands % 1 == 0) {
      return '${thousands.toInt()}K';
    }
    
    // Si tiene decimales, mostrar 1 decimal
    return '${thousands.toStringAsFixed(1)}K';
  } catch (e) {
    return amount;
  }
}

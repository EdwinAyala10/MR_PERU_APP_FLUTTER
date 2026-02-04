class DistanceFilter {
  final String valor;
  final String descripcion;

  DistanceFilter({
    required this.valor,
    required this.descripcion,
  });

  // Método helper para obtener el valor numérico de distancia
  double get distanceValue {
    final value = double.tryParse(valor) ?? 0;
    return value.abs(); // Retorna el valor absoluto (5, 10, 20)
  }

  // Método helper para verificar si es "Todos"
  bool get isAll => valor == "0";

  @override
  String toString() =>
      'DistanceFilter(valor: $valor, descripcion: $descripcion)';
}

import '../../domain/entities/distance_filter.dart';

class DistanceFilterMapper {
  static DistanceFilter jsonToEntity(Map<String, dynamic> json) {
    return DistanceFilter(
      valor: json['VALOR'] ?? '0',
      descripcion: json['DESCRIPCION'] ?? '',
    );
  }

  static List<DistanceFilter> jsonToList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => jsonToEntity(json as Map<String, dynamic>))
        .toList();
  }
}

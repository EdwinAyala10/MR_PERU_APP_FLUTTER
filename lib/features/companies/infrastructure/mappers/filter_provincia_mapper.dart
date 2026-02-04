import '../../domain/domain.dart';

class FilterProvinciaMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) => FilterProvincia(
        provincia: json['PROVINCIA'] ?? '',
      );
}

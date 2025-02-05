import '../../domain/domain.dart';


class FilterDistritoMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => FilterDistrito(
    distrito: json['DISTRITO'] ?? '',
  );

}

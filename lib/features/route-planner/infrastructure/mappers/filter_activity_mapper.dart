import '../../domain/domain.dart';


class FilterActivityMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => FilterActivity(
    valor: json['VALOR'] ?? '',
    descripcion: json['DESCRIPCION'] ?? '',
  );

}

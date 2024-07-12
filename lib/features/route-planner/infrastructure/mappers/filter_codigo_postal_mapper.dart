import '../../domain/domain.dart';


class FilterCodigoPostalMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => FilterCodigoPostal(
    localCodigoPostal: json['LOCAL_CODIGO_POSTAL'] ?? '',
  );

}

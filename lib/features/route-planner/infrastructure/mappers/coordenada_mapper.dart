import 'package:crm_app/features/route-planner/domain/entities/coordenada.dart';

class CoordenadaMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Coordenada(
    latitud: json['PLCP_LATITUD'] ?? '',
    longitud: json['PLCP_LONGITUD'] ?? '',
  );

}

import '../../domain/domain.dart';

class FilterEstadoMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) => FilterEstado(
        valor: json['ESTADO_ID'] ?? '',
        descripcion: json['ESTADO_NOMBRE'] ?? '',
      );
}

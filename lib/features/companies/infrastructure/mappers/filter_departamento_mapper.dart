import '../../domain/domain.dart';

class FilterDepartamentoMapper {
  static jsonToEntity(Map<dynamic, dynamic> json) => FilterDepartamento(
        departamento: json['DEPARTAMENTO'] ?? '',
      );
}

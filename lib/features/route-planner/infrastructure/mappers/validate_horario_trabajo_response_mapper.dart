import 'package:crm_app/features/route-planner/domain/entities/validate_horario_trabajo_response.dart';

class ValidateHorarioTrabajoResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ValidateHorarioTrabajoResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );
}

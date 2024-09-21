

import 'package:crm_app/features/route-planner/domain/entities/validar_horario_trabajo.dart';

class ValidateHorarioTrabajoResponse {
    String type;
    String icon;
    bool status;
    String message;
    ValidarHorarioTrabajo? data;

    ValidateHorarioTrabajoResponse({
        required this.type,
        required this.icon,
        required this.status,
        required this.message,
        this.data,
    });
}

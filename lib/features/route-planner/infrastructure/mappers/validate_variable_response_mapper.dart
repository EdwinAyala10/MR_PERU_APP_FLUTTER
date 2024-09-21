

import 'package:crm_app/features/route-planner/domain/entities/validate_event_planner.dart';

class ValidateVariableResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ValidateEventPlanner(
    totalLocales: json['TOTAL_LOCALES'] ?? '',
    totalDias: json['TOTAL_DIAS'] ?? '',
    fechaIni: json['FECHAINI'] ?? '',
    fechaFin: json['FECHAFIN'] ?? '',
  );
}

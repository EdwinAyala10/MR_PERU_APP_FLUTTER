import 'package:crm_app/features/route-planner/domain/entities/evento_planificador_ruta_array.dart';

class EventPlanner {
  String id;
  //String? evntAsunto;
  DateTime evntFechaInicioEvento;
  String evntHoraInicioEvento;
  String evntIdTipoGestion;
  String? evntNombreTipoGestion;
  //int evntIdRecordatorio;
  String evntIdIntervaloReunion;
  String evntNombreIntervaloReunion;
  String? evntNombreRecordatorio;
  String evntIdUsuarioResponsable;
  String? evntNombreUsuarioResponsable;
  List<EventoPlanificadorRutaArray>? arrayEventosPlanificadorRuta;

  EventPlanner({
    required this.id,
    //this.evntAsunto,
    required this.evntFechaInicioEvento,
    required this.evntHoraInicioEvento,
    required this.evntIdTipoGestion,
    this.evntNombreTipoGestion,
    //required this.evntIdRecordatorio,
    required this.evntIdIntervaloReunion,
    required this.evntNombreIntervaloReunion,
    this.evntNombreRecordatorio,
    required this.evntIdUsuarioResponsable,
    required this.evntNombreUsuarioResponsable,
    this.arrayEventosPlanificadorRuta,
  });
}

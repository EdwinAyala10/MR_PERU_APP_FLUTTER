import 'package:crm_app/features/route-planner/domain/entities/evento_planificador_ruta_array.dart';

class EventPlanner {
  String id;
  //String? evntAsunto;
  DateTime evntFechaInicioEvento;
  String evntHoraInicioEvento;
  DateTime evntFechaTerminoEvento;
  String evntIdTipoGestion;
  String? evntNombreTipoGestion;
  String? horarioTrabajoNombre;
  String? horarioTrabajoId;

  String? tiempoEntreVisitasId;
  String? tiempoEntreVisitasNombre;
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
    required this.evntFechaTerminoEvento,
    required this.evntHoraInicioEvento,
    required this.evntIdTipoGestion,
    this.evntNombreTipoGestion,

    this.horarioTrabajoNombre,
    this.horarioTrabajoId,
    this.tiempoEntreVisitasId,
    this.tiempoEntreVisitasNombre,

    //required this.evntIdRecordatorio,
    required this.evntIdIntervaloReunion,
    required this.evntNombreIntervaloReunion,
    this.evntNombreRecordatorio,
    required this.evntIdUsuarioResponsable,
    required this.evntNombreUsuarioResponsable,
    this.arrayEventosPlanificadorRuta,
  });
}

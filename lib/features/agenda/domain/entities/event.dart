import 'package:crm_app/features/contacts/domain/entities/contact_array.dart';

class Event {
  String id;
  String evntAsunto;
  DateTime? evntFechaInicioEvento;
  DateTime? evntFechaFinEvento;
  String? evntHoraInicioEvento;
  String? evntHoraFinEvento;
  String? evntHoraRecordatorio;
  String? evntIdUsuarioResponsable;
  String? evntNombreUsuarioResponsable;
  String? evntIdTipoGestion;
  String? evntRuc;
  String? evntRazon;
  String? evntIdOportunidad;
  String? evntComentario;
  String? evntUbigeo;
  String? evntCoordenadaLatitud;
  String? evntCoordenadaLongitud;
  String? evntDireccionMapa;
  int? evntIdRecordatorio;
  String? evntNombreRecordatorio;
  String? evntIdUsuarioRegistro;
  String? opt;
  String? todoDia;
  String? evntIdEventoIn;
  String? evntNombreTipoGestion;
  String? evntNombreOportunidad;
  String? evntCorreosExternos;
  List<ContactArray>? arraycontacto;
  List<ContactArray>? arraycontactoElimimar;

  Event({
    required this.id,
    required this.evntAsunto,
    this.evntHoraInicioEvento,
    this.evntHoraFinEvento,
    this.evntHoraRecordatorio,
    this.evntIdUsuarioResponsable,
    this.evntNombreUsuarioResponsable,
    this.evntIdTipoGestion,
    this.evntRuc,
    this.evntRazon,
    this.evntIdOportunidad,
    this.evntComentario,
    this.evntUbigeo,
    this.evntCoordenadaLatitud,
    this.evntCoordenadaLongitud,
    this.evntDireccionMapa,
    this.evntIdRecordatorio,
    this.evntNombreRecordatorio,
    this.evntIdUsuarioRegistro,
    this.opt,
    this.todoDia,
    this.evntIdEventoIn,
    this.evntNombreTipoGestion,
    this.evntNombreOportunidad,
    this.evntCorreosExternos,
    this.evntFechaInicioEvento,
    this.evntFechaFinEvento,
    this.arraycontacto,
    this.arraycontactoElimimar,
  });
}

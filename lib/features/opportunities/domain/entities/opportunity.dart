import '../../../kpis/domain/entities/array_user.dart';

class Opportunity {
  String id;
  String oprtNombre;
  String? oprtEntorno;
  String? oprtIdEstadoOportunidad;
  String? oprtProbabilidad;
  String? oprtIdValor;
  String? oprtValor;
  DateTime? oprtFechaPrevistaVenta;
  String? oprtRuc;
  String? oprtLocalCodigo;
  String? oprtLocalNombre;
  String? oprtRazon;
  String? oprtRucIntermediario01;
  String? oprtRucIntermediario02;
  String? oprtComentario;
  String? oprtIdUsuarioRegistro;
  String? oprtNobbreEstadoOportunidad;
  String? oprtNombreValor;
  String? opt;
  String? oprtIdOportunidadIn;
  List<ArrayUser>? arrayresponsables;
  List<ArrayUser>? arrayresponsablesEliminar;
  String? razonComercial;
  String? razon;
  String? localDistrito;
  String? contacTelefono;
  String? contactId;

  Opportunity({
    required this.id,
    required this.oprtNombre,
    this.oprtEntorno,
    this.oprtIdEstadoOportunidad,
    this.oprtProbabilidad,
    this.oprtIdValor,
    this.oprtFechaPrevistaVenta,
    this.oprtRuc,
    this.oprtRazon,
    this.oprtRucIntermediario01,
    this.oprtRucIntermediario02,
    this.oprtComentario,
    this.oprtIdUsuarioRegistro,
    this.oprtNobbreEstadoOportunidad,
    this.oprtNombreValor,
    this.oprtValor,
    this.opt,
    this.oprtIdOportunidadIn,
    this.arrayresponsables,
    this.arrayresponsablesEliminar,
    this.razon,
    this.razonComercial,
    this.localDistrito,
    this.oprtLocalCodigo,
    this.oprtLocalNombre,
    this.contacTelefono,
    this.contactId,
  });
}

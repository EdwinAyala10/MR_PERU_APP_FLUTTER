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
  String? oprtIdContacto;
  String? oprtNombreContacto;
  String? actiIdTipoGestion;
  String? actiNombreTipoGestion;
  String? actiFechaRegistro;
  String? nombreUsuarioResponsable;
  String? actiComentario;
  String? emlsAsunto;
  String? subject;
  DateTime? oprtFechaRegistro;
  bool isFirstInGroup;
  String? oprtPrimeraFechaRegistro;
  String? nombrePrimeroUsuarioResponsable;
  int? totalOportunidadesEnGrupo;
  List<Opportunity>? oportunidadesDelGrupo;
  List<Opportunity>? visibleOportunidadesDelGrupo;

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
    this.oprtIdContacto,
    this.oprtNombreContacto,
    this.actiIdTipoGestion,
    this.actiNombreTipoGestion,
    this.actiFechaRegistro,
    this.nombreUsuarioResponsable,
    this.actiComentario,
    this.emlsAsunto,
    this.subject,
    this.oprtFechaRegistro,
    this.isFirstInGroup = false,
    this.oprtPrimeraFechaRegistro,
    this.nombrePrimeroUsuarioResponsable,
    this.totalOportunidadesEnGrupo,
    this.oportunidadesDelGrupo,
    this.visibleOportunidadesDelGrupo,
  });

  /// Clave de empresa (RUC + local). Se usa para agrupar/fusionar
  /// oportunidades de una misma empresa y evitar cards divididos.
  String get empresaKey => '${oprtRuc ?? ''}-${oprtLocalCodigo ?? ''}';

  /// Agrupa una lista plana de oportunidades por empresa (RUC + local),
  /// devolviendo una oportunidad "representante" por empresa con todas las
  /// oportunidades de esa empresa en [oportunidadesDelGrupo].
  ///
  /// Se usa en los flujos que todavía reciben oportunidades sueltas
  /// (Dashboard, Detalle de empresa) para alimentar `ItemOpportunity` con la
  /// misma estructura agrupada que entrega el endpoint agrupado por empresa,
  /// evitando dividir una empresa en varios cards.
  static List<Opportunity> agruparPorEmpresa(List<Opportunity> opportunities) {
    final Map<String, Opportunity> representantes = {};
    final List<Opportunity> orden = [];

    for (final o in opportunities) {
      final rep = representantes[o.empresaKey];
      if (rep == null) {
        o.isFirstInGroup = true;
        o.oportunidadesDelGrupo = [o];
        o.visibleOportunidadesDelGrupo = [o];
        o.totalOportunidadesEnGrupo = 1;
        representantes[o.empresaKey] = o;
        orden.add(o);
      } else {
        rep.oportunidadesDelGrupo!.add(o);
        rep.visibleOportunidadesDelGrupo!.add(o);
        rep.totalOportunidadesEnGrupo = rep.oportunidadesDelGrupo!.length;
      }
    }

    return orden;
  }
}

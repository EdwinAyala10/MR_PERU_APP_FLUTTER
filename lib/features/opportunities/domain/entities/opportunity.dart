
import '../../../kpis/domain/entities/array_user.dart';

class Opportunity {
    String id;
    String oprtNombre;
    String? oprtEntorno;
    String? oprtIdEstadoOportunidad;
    String? oprtProbabilidad;
    String? oprtIdValor;
    int? oprtValor;
    DateTime? oprtFechaPrevistaVenta;
    String? oprtRuc;
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

    Opportunity({
        required this.id,
        required this.oprtNombre,
        this.oprtEntorno,
        this.oprtIdEstadoOportunidad,
        this.oprtProbabilidad,
        this.oprtIdValor,
        this.oprtFechaPrevistaVenta,
        this.oprtRuc,
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
    });

    
}

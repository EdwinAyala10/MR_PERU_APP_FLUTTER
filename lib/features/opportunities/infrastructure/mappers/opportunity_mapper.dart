import 'package:crm_app/features/opportunities/domain/domain.dart';


class OpportunityMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Opportunity(
    id: json['OPRT_ID_OPORTUNIDAD'] ?? '',
    oprtEntorno: json['OPRT_ENTORNO'] ?? '',
    oprtIdEstadoOportunidad: json['OPRT_ID_ESTADO_OPORTUNIDAD'] ?? '',
    oprtNombre: json['OPRT_NOMBRE'] ?? '',
    oprtComentario: json['OPRT_COMENTARIO'] ?? '',
    oprtFechaPrevistaVenta: json['OPRT_FECHA_PREVISTA_VENTA'] ?? '',
    oprtIdOportunidadIn: json['OPRT_ID_OPORTUNIDAD_IN'] ?? '',
    oprtIdUsuarioRegistro: json['OPRT_ID_USUARIO_REGISTRO'] ?? '',
    oprtIdValor: json['OPRT_ID_VALOR'] ?? '',
    oprtNobbreEstadoOportunidad: json['OPRT_NOBBRE_ESTADO_OPORTUNIDAD'] ?? '',
    oprtNombreValor: json['OPRT_NOMBRE_VALOR'] ?? '',
    oprtProbabilidad: json['OPRT_PROBABILIDAD'] ?? '',
    oprtRuc: json['OPRT_RUC'] ?? '',
    oprtRucIntermediario01: json['OPRT_RUC_INTERMEDIARIO_01'] ?? '',
    oprtRucIntermediario02: json['OPRT_RUC_INTERMEDIARIO_02'] ?? '',
    opt: json['OPT'] ?? '',
  );

}

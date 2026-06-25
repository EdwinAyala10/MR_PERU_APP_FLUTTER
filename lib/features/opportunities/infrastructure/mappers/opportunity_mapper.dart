import 'dart:convert';
import '../../../kpis/domain/entities/array_user.dart';
import '../../domain/domain.dart';


class OpportunityMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) {
    // Extraer JSON de Microsoft para emails (similar a ActivityMapper)
    Map<String, dynamic>? jsonMicrosoft;
    if (json['EMLS_JSON_EMAIL_MICROSOFT'] is Map) {
      jsonMicrosoft = Map<String, dynamic>.from(json['EMLS_JSON_EMAIL_MICROSOFT']);
    } else if (json['EMLS_JSON_EMAIL_MICROSOFT'] is String) {
      final rawJsonMicrosoft = json['EMLS_JSON_EMAIL_MICROSOFT'].toString();
      if (rawJsonMicrosoft.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawJsonMicrosoft);
          if (decoded is Map<String, dynamic>) {
            jsonMicrosoft = decoded;
          } else if (decoded is Map) {
            jsonMicrosoft = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    }
    
    // Obtener subject del JSON de Microsoft si existe
    final subjectData = jsonMicrosoft?['subject'] ?? json['subject'];
    
    return Opportunity(
    id: json['OPRT_ID_OPORTUNIDAD'] ?? '',
    oprtEntorno: json['OPRT_ENTORNO'] ?? '',
    oprtIdEstadoOportunidad: json['OPRT_ID_ESTADO_OPORTUNIDAD'] ?? '',
    oprtNombre: json['OPRT_NOMBRE'] ?? '',
    oprtComentario: json['OPRT_COMENTARIO'] ?? '',
    oprtFechaPrevistaVenta: json['OPRT_FECHA_PREVISTA_VENTA'] != null ? DateTime.parse(json['OPRT_FECHA_PREVISTA_VENTA']) : DateTime.now(),

    oprtIdOportunidadIn: json['OPRT_ID_OPORTUNIDAD_IN'] ?? '',
    oprtIdUsuarioRegistro: json['OPRT_ID_USUARIO_REGISTRO'] ?? '',
    oprtIdValor: json['OPRT_ID_VALOR'] ?? '',
    oprtNobbreEstadoOportunidad: json['OPRT_NOBBRE_ESTADO_OPORTUNIDAD'] ?? '',
    oprtNombreValor: json['OPRT_NOMBRE_VALOR'] ?? '',
    oprtValor: json['OPRT_VALOR'] ?? '0',
    oprtProbabilidad: json['OPRT_PROBABILIDAD'] ?? '',
    oprtRuc: json['OPRT_RUC'] ?? '',
    oprtLocalCodigo: json['OPRT_LOCAL_CODIGO'] ?? '',
    oprtLocalNombre: json['LOCAL_NOMBRE'] ?? '',
    oprtRazon: json['RAZON'] ?? '',
    oprtRucIntermediario01: json['OPRT_RUC_INTERMEDIARIO_01'] ?? '',
    oprtRucIntermediario02: json['OPRT_RUC_INTERMEDIARIO_02'] ?? '',
    opt: json['OPT'] ?? '',
    arrayresponsables: json["OPORTUNIDAD_RESPONSABLE"] != null ? List<ArrayUser>.from(json["OPORTUNIDAD_RESPONSABLE"].map((x) => ArrayUser.fromJson(x))) : [],
    razon: json['RAZON'] ?? '',
    razonComercial: json['RAZON_COMERCIAL'] ?? '',
    localDistrito: json['LOCAL_DISTRITO'] ?? '',
    contacTelefono: json['CONTACTO_TELEFONOC'],
    contactId: json['CONTACTO_ID'] ?? '',
    oprtIdContacto: json['OPRT_ID_CONTACTO'] ?? '',
    oprtNombreContacto: json['CONTACTO_DESC'] ?? '',
    actiIdTipoGestion: json["ACTI_ID_TIPO_GESTION"],
    actiNombreTipoGestion: json["ACTI_NOMBRE_TIPO_GESTION"],
    actiFechaRegistro: json["ACTI_FECHA_REGISTRO"],
    nombreUsuarioResponsable: json['NOMBRE_USUARIO_RESPONSABLE'] ?? '',
    actiComentario: json['ACTI_COMENTARIO'] ?? '',
    emlsAsunto: json['EMLS_ASUNTO'] ?? '',
    subject: subjectData?.toString() ?? '',
    oprtFechaRegistro: json['OPRT_FECHA_REGISTRO'] != null
        ? DateTime.tryParse(json['OPRT_FECHA_REGISTRO'].toString())
        : null,
    );
  }

}

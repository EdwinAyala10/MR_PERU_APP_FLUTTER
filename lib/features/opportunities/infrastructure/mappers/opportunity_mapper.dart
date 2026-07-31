import 'dart:convert';
import '../../../kpis/domain/entities/array_user.dart';
import '../../domain/domain.dart';

class OpportunityMapper {
  /// Parseo tolerante de fechas provenientes del backend. Producción puede
  /// enviar fechas en formatos que `DateTime.parse` no soporta (o vacías), y
  /// un solo registro inválido no debe tumbar toda la carga de la pestaña.
  static DateTime? _tryParseDate(dynamic rawValue) {
    if (rawValue == null) return null;
    final value = rawValue.toString().trim();
    if (value.isEmpty) return null;

    final direct = DateTime.tryParse(value);
    if (direct != null) return direct;

    // Formatos comunes: "dd/MM/yyyy", "dd-MM-yyyy", con u sin hora.
    final normalized = value.replaceAll('/', '-');
    final datePart = normalized.split(' ').first;
    final segments = datePart.split('-');
    if (segments.length == 3) {
      final a = int.tryParse(segments[0]);
      final b = int.tryParse(segments[1]);
      final c = int.tryParse(segments[2]);
      if (a != null && b != null && c != null) {
        // Si el primer segmento tiene 4 dígitos es yyyy-MM-dd, si no dd-MM-yyyy.
        if (segments[0].length == 4) {
          final parsed = DateTime.tryParse(
            '${segments[0]}-${segments[1].padLeft(2, '0')}-${segments[2].padLeft(2, '0')}',
          );
          if (parsed != null) return parsed;
        } else {
          final parsed = DateTime.tryParse(
            '${segments[2]}-${segments[1].padLeft(2, '0')}-${segments[0].padLeft(2, '0')}',
          );
          if (parsed != null) return parsed;
        }
      }
    }

    return null;
  }

  static jsonToEntity(Map<dynamic, dynamic> json) {
    // Extraer JSON de Microsoft para emails (similar a ActivityMapper)
    Map<String, dynamic>? jsonMicrosoft;
    if (json['EMLS_JSON_EMAIL_MICROSOFT'] is Map) {
      jsonMicrosoft =
          Map<String, dynamic>.from(json['EMLS_JSON_EMAIL_MICROSOFT']);
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
      oprtFechaPrevistaVenta:
          _tryParseDate(json['OPRT_FECHA_PREVISTA_VENTA']) ?? DateTime.now(),
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
      arrayresponsables: json["OPORTUNIDAD_RESPONSABLE"] != null
          ? List<ArrayUser>.from(
              json["OPORTUNIDAD_RESPONSABLE"].map((x) => ArrayUser.fromJson(x)))
          : [],
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
      actiFechaRegistroDias: json["ACTI_FECHA_REGISTRO_DIAS"]?.toString(),
      nombreUsuarioResponsable: json['NOMBRE_USUARIO_RESPONSABLE'] ?? '',
      actiComentario: json['ACTI_COMENTARIO'] ?? '',
      emlsAsunto: json['EMLS_ASUNTO'] ?? '',
      subject: subjectData?.toString() ?? '',
      oprtFechaRegistro: _tryParseDate(json['OPRT_FECHA_REGISTRO']),
    );
  }
}

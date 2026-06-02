import 'dart:convert';

import '../../domain/domain.dart';
import '../../../contacts/domain/domain.dart';


class ActivityMapper {

  static Activity jsonToEntity(Map<dynamic, dynamic> json) {
    // Extraer JSON de Microsoft (puede venir como Map o String)
    Map<String, dynamic>? jsonMicrosoft;
    final rawMs = json['EMLS_JSON_EMAIL_MICROSOFT'];
    if (rawMs is Map) {
      jsonMicrosoft = Map<String, dynamic>.from(rawMs);
    } else if (rawMs is String && rawMs.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMs);
        if (decoded is Map) {
          jsonMicrosoft = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final bodyData = jsonMicrosoft?['body'] ?? json['body'];
    final subjectData = jsonMicrosoft?['subject'] ?? json['subject'];
    final bodyPreviewData = jsonMicrosoft?['bodyPreview'] ?? json['bodyPreview'];

    bool? isReadValue;
    if (json['EMLS_ISREAD'] != null) {
      // "1" = leído, "0" = no leído, null = no enviado
      final readString = json['EMLS_ISREAD'].toString();
      isReadValue = readString == '1' || readString.toLowerCase() == 'true';
    } else if (jsonMicrosoft?['isRead'] is bool) {
      isReadValue = jsonMicrosoft!['isRead'];
    }

    return Activity(
      id: json['ACTI_ID_ACTIVIDAD'] ?? '',
      actiComentario: json['ACTI_COMENTARIO'] ?? '',
      actiEstadoReg: json['ACTI_ESTADO_REG'] ?? '',
      actiFechaActividad: DateTime.parse(json["ACTI_FECHA_ACTIVIDAD"]),
      actiHoraActividad: json['ACTI_HORA_ACTIVIDAD'] ?? '',
      actiIdContacto: json['ACTI_ID_CONTACTO'] ?? '',
      actiIdOportunidad: json['ACTI_ID_OPORTUNIDAD'] ?? '',
      actiIdTipoGestion: json['ACTI_ID_TIPO_GESTION'] ?? '',
      actiIdUsuarioRegistro: json['ACTI_ID_USUARIO_REGISTRO'] ?? '',
      actiIdUsuarioResponsable: json['ACTI_ID_USUARIO_RESPONSABLE'] ?? '',
      actiNombreArchivo: json['ACTI_NOMBRE_ARCHIVO'] ?? '',
      actiNombreOportunidad: json['ACTI_NOMBRE_OPORTUNIDAD'] ?? '',
      actiNombreTipoGestion: json['ACTI_NOMBRE_TIPO_GESTION'] ?? '',
      actiTiempoGestion: json['ACTI_TIEMPO_GESTION'] ?? '',
      cchkComentarioCheckIn: json['CCHK_COMENTARIO_CHECK_IN'] ?? '',
      cchkComentarioCheckOut: json['CCHK_COMENTARIO_CHECK_OUT'] ?? '',
      actiRuc: json['ACTI_RUC'] ?? '',
      actiRazon: json['ACTI_RAZON'] ?? '',
      contactoDesc: json['CONTACTO_DESC'] ?? '',
      actiNombreResponsable: json['ACTI_NOMBRE_RESPONSABLE'] ?? '',
      cchkFechaRegistroCheckIn: json['CCHK_FECHA_REGISTRO_CHECK_IN'] ?? '',
      cchkFechaRegistroCheckOut: json['CCHK_FECHA_REGISTRO_CHECK_OUT'] ?? '',
      actiIdUsuarioActualizacion: json['ACTI_ID_USUARIO_ACTUALIZACION'] ?? '',
      actiIdActividadIn: json['ACTI_ID_ACTIVIDAD_IN'] ?? '',
      actiIdTipoRegistro: json['ACTI_ID_TIPO_REGISTRO'] ?? '',
      actividadesContacto: json["ACTIVIDADES_CONTACTO"] != null
          ? List<ContactArray>.from(
              json["ACTIVIDADES_CONTACTO"].map((x) => ContactArray.fromJson(x)))
          : [],
      actividadesContactoEliminar: json["ACTIVIDADES_CONTACTO_ELIMINAR"] != null
          ? List<ContactArray>.from(json["ACTIVIDADES_CONTACTO_ELIMINAR"]
              .map((x) => ContactArray.fromJson(x)))
          : [],
      opt: json['OPT'] ?? '',
      coordenadaLongitud: json['COORDENADA_LONGITUD'] ?? '',
      coordenadalatitud: json['COORDENADA_LATITUD'] ?? '',
      localNombre: json['LOCAL_NOMBRE'] ?? '',
      // Email
      emlsEmailFrom: json['EMLS_EMAIL_FROM'] ?? '',
      emlsEmailTo: json['EMLS_EMAIL_TO'] ?? '',
      emlsIdTipoMailfolders: json['EMLS_ID_TIPO_MAILFOLDERS'] ?? '',
      emlsAsunto: (json['EMLS_ASUNTO'] ?? '').toString(),
      subject: _resolveSubject(subjectData, json['EMLS_ASUNTO']),
      bodyPreview: bodyPreviewData?.toString() ?? '',
      emailHtmlContent: _resolveEmailBody(bodyData, json['ACTI_COMENTARIO']),
      isRead: isReadValue,
      emlsJsonEmailMicrosoft: jsonMicrosoft,
      toRecipients: _mapToRecipients(jsonMicrosoft?['toRecipients']),
      ccRecipients: _mapToRecipients(jsonMicrosoft?['ccRecipients']),
      bccRecipients: _mapToRecipients(jsonMicrosoft?['bccRecipients']),
      attachments: _mapAttachments(jsonMicrosoft?['attachments']),
    );
  }

  static String _extractHtmlContent(dynamic body) {
    if (body is Map && body['content'] != null) {
      return body['content'].toString();
    }
    if (body is String) return body;
    return '';
  }

  static String _resolveSubject(dynamic subject, dynamic emlsAsunto) {
    final msSubject = (subject ?? '').toString().trim();
    if (msSubject.isNotEmpty) return msSubject;
    final legacySubject = (emlsAsunto ?? '').toString().trim();
    if (legacySubject.isNotEmpty) return legacySubject;
    return '';
  }

  static String _resolveEmailBody(dynamic body, dynamic actiComentario) {
    final fromMicrosoft = _extractHtmlContent(body).trim();
    if (fromMicrosoft.isNotEmpty) return fromMicrosoft;
    final fromActivity = (actiComentario ?? '').toString().trim();
    if (fromActivity.isNotEmpty) return fromActivity;
    return '';
  }

  static List<EmailRecipient> _mapToRecipients(dynamic recipients) {
    if (recipients is! List) return const [];
    return recipients.whereType<Map>().map((item) {
      final emailAddress = item['emailAddress'];
      if (emailAddress is Map) {
        return EmailRecipient(
          name: (emailAddress['name'] ?? '').toString(),
          address: (emailAddress['address'] ?? '').toString(),
        );
      }
      return const EmailRecipient(name: '', address: '');
    }).where((r) => r.address.isNotEmpty).toList();
  }

  static List<EmailAttachment> _mapAttachments(dynamic attachments) {
    print('========== _mapAttachments DEBUG ==========');
    print('attachments type: ${attachments.runtimeType}');
    print('attachments is List: ${attachments is List}');
    if (attachments is List) {
      print('attachments length: ${attachments.length}');
      print('attachments raw: $attachments');
    }
    print('===========================================');
    
    if (attachments is! List) return const [];

    int counter = 1;
    return attachments.whereType<Map>().map((item) {
      final rawName = (item['name'] ?? '').toString().trim();
      final rawContentType = (item['contentType'] ?? '').toString().trim();
      final contentBytes = (item['contentBytes'] ?? '').toString();
      int size = int.tryParse((item['size'] ?? 0).toString()) ?? 0;

      // Calcular tamaño real desde base64 si size=0
      if (size == 0 && contentBytes.isNotEmpty) {
        size = (contentBytes.length * 3 / 4).round();
      }

      // Detectar tipo desde magic numbers en base64 (SIEMPRE, aunque venga contentType)
      // porque Microsoft a veces envía contentType null
      String detectedType = rawContentType;
      String detectedExtension = '';
      
      if (contentBytes.isNotEmpty) {
        final type = _detectFileTypeFromBase64(contentBytes);
        // Si no hay contentType o está vacío, usar el detectado
        if (detectedType.isEmpty || detectedType == 'null') {
          detectedType = type.mime;
        }
        detectedExtension = type.extension;
      } else if (detectedType.isNotEmpty && detectedType != 'null') {
        detectedExtension = _extensionFromMime(detectedType);
      }

      // Generar nombre del archivo
      String finalName = rawName;
      if (finalName.isEmpty || finalName == 'null') {
        finalName = detectedExtension.isNotEmpty
            ? 'adjunto_$counter.$detectedExtension'
            : 'adjunto_$counter';
      } else if (!finalName.contains('.') && detectedExtension.isNotEmpty) {
        // Si tiene nombre pero no extensión, agregarla
        finalName = '$finalName.$detectedExtension';
      }
      counter++;

      print('Mapped attachment ${counter - 1}: $finalName (${detectedType}, ${size} bytes)');
      
      return EmailAttachment(
        name: finalName,
        contentBytes: contentBytes,
        contentType: detectedType.isEmpty || detectedType == 'null' 
            ? 'application/octet-stream' 
            : detectedType,
        size: size,
      );
    }).toList()..forEach((att) {
      print('Final attachment in list: ${att.name}');
    });
  }

  /// Detecta tipo de archivo desde los magic numbers en base64
  static ({String mime, String extension}) _detectFileTypeFromBase64(String b64) {
    if (b64.isEmpty) return (mime: 'application/octet-stream', extension: 'bin');
    final prefix = b64.length >= 8 ? b64.substring(0, 8) : b64;

    if (prefix.startsWith('JVBERi')) return (mime: 'application/pdf', extension: 'pdf');
    if (prefix.startsWith('iVBORw0K')) return (mime: 'image/png', extension: 'png');
    if (prefix.startsWith('/9j/')) return (mime: 'image/jpeg', extension: 'jpg');
    if (prefix.startsWith('R0lGOD')) return (mime: 'image/gif', extension: 'gif');
    if (prefix.startsWith('UEsDB')) return (mime: 'application/zip', extension: 'zip');
    if (prefix.startsWith('PK')) return (mime: 'application/zip', extension: 'zip');
    if (prefix.startsWith('0M8R4K')) return (mime: 'application/msword', extension: 'doc');
    if (prefix.startsWith('UklGR')) return (mime: 'audio/wav', extension: 'wav');
    if (prefix.startsWith('SUQzB')) return (mime: 'audio/mp3', extension: 'mp3');
    if (prefix.startsWith('AAAAI')) return (mime: 'video/mp4', extension: 'mp4');

    return (mime: 'application/octet-stream', extension: 'bin');
  }

  static String _extensionFromMime(String mime) {
    const map = {
      'application/pdf': 'pdf',
      'image/png': 'png',
      'image/jpeg': 'jpg',
      'image/jpg': 'jpg',
      'image/gif': 'gif',
      'application/zip': 'zip',
      'application/msword': 'doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
      'application/vnd.ms-excel': 'xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
      'text/plain': 'txt',
      'audio/mp3': 'mp3',
      'audio/wav': 'wav',
      'video/mp4': 'mp4',
    };
    return map[mime.toLowerCase()] ?? '';
  }
}

import '../../../contacts/domain/domain.dart';

class Activity {
  String id;
  String actiIdUsuarioResponsable;
  String actiIdTipoGestion;
  DateTime actiFechaActividad;
  String actiHoraActividad;
  String actiRuc;
  String? actiRazon;
  String actiIdOportunidad;
  String actiIdContacto;
  String actiComentario;
  String actiNombreArchivo;
  String actiIdUsuarioRegistro;
  String actiEstadoReg;
  String actiNombreTipoGestion;
  String actiNombreOportunidad;
  String? actiIdUsuarioActualizacion;
  String? opt;
  String? actiIdActividadIn;
  String? cchkComentarioCheckIn;
  String? cchkComentarioCheckOut;
  String? actiTiempoGestion;
  String? actiTiempoGestionLlamada;
  String? actiNombreResponsable;
  String? contactoDesc;
  String? actiIdTipoRegistro;
  List<ContactArray>? actividadesContacto;
  List<ContactArray>? actividadesContactoEliminar;
  String? cchkFechaRegistroCheckIn;
  String? cchkFechaRegistroCheckOut;
  String? coordenadalatitud;
  String? coordenadaLongitud;
  String? localNombre;

  // Campos de email (correo Microsoft)
  String? emlsEmailFrom;
  String? emlsEmailTo;
  String? emlsIdTipoMailfolders;
  String? emlsAsunto;
  String? subject;
  String? bodyPreview;
  String? emailHtmlContent;
  bool? isRead;
  Map<String, dynamic>? emlsJsonEmailMicrosoft;
  List<EmailRecipient>? toRecipients;
  List<EmailRecipient>? ccRecipients;
  List<EmailRecipient>? bccRecipients;
  List<EmailAttachment>? attachments;

  Activity(
      {required this.id,
      required this.actiIdUsuarioResponsable,
      required this.actiIdTipoGestion,
      required this.actiFechaActividad,
      required this.actiHoraActividad,
      required this.actiRuc,
      required this.actiIdOportunidad,
      required this.actiIdContacto,
      required this.actiComentario,
      required this.actiNombreArchivo,
      required this.actiIdUsuarioRegistro,
      required this.actiEstadoReg,
      required this.actiNombreTipoGestion,
      required this.actiNombreOportunidad,
      this.actiIdUsuarioActualizacion,
      this.actiIdActividadIn,
      this.opt,
      this.actividadesContacto,
      this.actividadesContactoEliminar,
      this.actiRazon,
      this.cchkComentarioCheckIn,
      this.cchkComentarioCheckOut,
      this.actiTiempoGestion,
      this.actiTiempoGestionLlamada,
      this.contactoDesc,
      this.actiIdTipoRegistro,
      this.cchkFechaRegistroCheckIn,
      this.cchkFechaRegistroCheckOut,
      this.actiNombreResponsable,
      this.coordenadalatitud,
      this.coordenadaLongitud,
      this.localNombre,
      this.emlsEmailFrom,
      this.emlsEmailTo,
      this.emlsIdTipoMailfolders,
      this.emlsAsunto,
      this.subject,
      this.bodyPreview,
      this.emailHtmlContent,
      this.isRead,
      this.emlsJsonEmailMicrosoft,
      this.toRecipients,
      this.ccRecipients,
      this.bccRecipients,
      this.attachments,
  });
}

class EmailRecipient {
  final String name;
  final String address;

  const EmailRecipient({
    required this.name,
    required this.address,
  });
}

class EmailAttachment {
  final String name;
  final String contentBytes;
  final String contentType;
  final int size;

  const EmailAttachment({
    required this.name,
    required this.contentBytes,
    required this.contentType,
    required this.size,
  });
}

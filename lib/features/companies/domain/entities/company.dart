import 'dart:convert';

Company companyFromJson(String str) => Company.fromJson(json.decode(str));

String companyToJson(Company data) => json.encode(data.toJson());

class Company {
  String ruc;
  String razon;
  String direccion;
  String telefono;
  String email;
  String tipocliente;
  String observaciones;
  String usuarioActualizacion;
  String estado;
  String departamento;
  String provincia;
  String distrito;
  String seguimientoComentario;
  String website;
  String calificacion;
  String visibleTodos;
  String codigoPostal;
  String usuarioRegistro;
  DateTime? fechaActualizacion;
  String? localNombre;
  String? localDireccion;
  String? localDepartamento;
  String? localProvincia;
  String? localDistrito;
  String? voltajeTension;
  String? enviarNotificacion;
  String? orden;
  String? localTipo;
  String? coordenadasGeo;
  String? coordenadasLongitud;
  String? coordenadasLatitud;
  String? ubigeoCodigo;
  String? localDepartamentoDesc;
  String? localProvinciaDesc;
  String? localDistritoDesc;

  Company({
    required this.ruc,
    required this.razon,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.tipocliente,
    required this.observaciones,
    required this.usuarioActualizacion,
    required this.estado,
    required this.departamento,
    required this.provincia,
    required this.distrito,
    required this.seguimientoComentario,
    required this.website,
    required this.calificacion,
    required this.visibleTodos,
    required this.codigoPostal,
    required this.usuarioRegistro,
    this.fechaActualizacion,
    this.localNombre,
    this.coordenadasGeo,
    this.coordenadasLatitud,
    this.coordenadasLongitud,
    this.enviarNotificacion,
    this.localDepartamento,
    this.localDepartamentoDesc,
    this.localDireccion,
    this.localDistrito,
    this.localProvincia,
    this.localDistritoDesc,
    this.localProvinciaDesc,
    this.localTipo,
    this.orden,
    this.ubigeoCodigo,
    this.voltajeTension,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        ruc: json["RUC"],
        razon: json["RAZON"],
        direccion: json["DIRECCION"],
        telefono: json["TELEFONO"],
        email: json["EMAIL"],
        tipocliente: json["TIPOCLIENTE"],
        observaciones: json["OBSERVACIONES"],
        usuarioActualizacion: json["USUARIO_ACTUALIZACION"],
        estado: json["ESTADO"],
        departamento: json["DEPARTAMENTO"],
        provincia: json["PROVINCIA"],
        distrito: json["DISTRITO"],
        seguimientoComentario: json["SEGUIMIENTO_COMENTARIO"],
        website: json["WEBSITE"],
        calificacion: json["CALIFICACION"],
        visibleTodos: json["VISIBLE_TODOS"],
        codigoPostal: json["CODIGO_POSTAL"],
        usuarioRegistro: json["USUARIO_REGISTRO"],
        fechaActualizacion: DateTime.parse(json["FECHA_ACTUALIZACION"]),
      );

  Map<String, dynamic> toJson() => {
        "RUC": ruc,
        "RAZON": razon,
        "DIRECCION": direccion,
        "TELEFONO": telefono,
        "EMAIL": email,
        "TIPOCLIENTE": tipocliente,
        "OBSERVACIONES": observaciones,
        "USUARIO_ACTUALIZACION": usuarioActualizacion,
        "ESTADO": estado,
        "DEPARTAMENTO": departamento,
        "PROVINCIA": provincia,
        "DISTRITO": distrito,
        "SEGUIMIENTO_COMENTARIO": seguimientoComentario,
        "WEBSITE": website,
        "CALIFICACION": calificacion,
        "VISIBLE_TODOS": visibleTodos,
        "CODIGO_POSTAL": codigoPostal,
        "USUARIO_REGISTRO": usuarioRegistro,
        "FECHA_ACTUALIZACION": fechaActualizacion?.toIso8601String(),
      };
}

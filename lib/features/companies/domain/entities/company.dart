class Company {
  String rucId;
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
  String? usuarioRegistro;
  String? idUsuarioRegistro;
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
    required this.rucId,
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
    this.usuarioRegistro,
    this.idUsuarioRegistro,
  });

}

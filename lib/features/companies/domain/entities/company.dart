import 'package:crm_app/features/kpis/domain/entities/array_user.dart';

class Company {
  String rucId;
  String ruc;
  String razon;
  String? direccion;
  String? telefono;
  String? email;
  String? tipocliente;
  String? observaciones;
  String? usuarioActualizacion;
  String? estado;
  String? departamento;
  String? provincia;
  String? distrito;
  String? seguimientoComentario;
  String? website;
  String? calificacion;
  String? visibleTodos;
  String? codigoPostal;
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
  String? cchkIdEstadoCheck;
  List<ArrayUser>? arrayresponsables;
  List<ArrayUser>? arrayresponsablesEliminar;

  //ARRAYRESPONSABLES

  Company({
    required this.rucId,
    required this.ruc,
    required this.razon,
    this.direccion,
    this.telefono,
    this.email,
    this.tipocliente,
    this.observaciones,
    this.usuarioActualizacion,
    this.estado,
    this.departamento,
    this.provincia,
    this.distrito,
    this.seguimientoComentario,
    this.website,
    this.calificacion,
    this.visibleTodos,
    this.codigoPostal,
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
    this.arrayresponsables,
    this.arrayresponsablesEliminar,
    this.cchkIdEstadoCheck,
  });

}

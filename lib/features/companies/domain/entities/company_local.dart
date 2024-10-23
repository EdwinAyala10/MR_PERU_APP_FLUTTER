class CompanyLocal {
  String id;
  String ruc;
  String localNombre;
  String? razon;
  String? localDireccion;
  String? localDepartamento;
  String? localProvincia;
  String? localDistrito;
  String? localTipo;
  String? coordenadasGeo;
  String? coordenadasLongitud;
  String? coordenadasLatitud;
  String? ubigeoCodigo;
  String? localDepartamentoDesc;
  String? localProvinciaDesc;
  String? localDistritoDesc;
  String? departamento;
  String? provincia;
  String? distrito;
  String? localCodigoPostal;
  String? localTipoDescripcion;
  String? localCoordenadasGeo;
  String? localCoordenadasLongitud;
  String? localCoordenadasLatitud;
  String? idUsuarioResponsable;

  CompanyLocal(
      {required this.id,
      required this.ruc,
      required this.localNombre,
      this.razon,
      this.localDireccion,
      this.localDepartamento,
      this.localProvincia,
      this.localDistrito,
      this.localTipo,
      this.coordenadasGeo,
      this.coordenadasLongitud,
      this.coordenadasLatitud,
      this.ubigeoCodigo,
      this.localDepartamentoDesc,
      this.localProvinciaDesc,
      this.localDistritoDesc,
      this.departamento,
      this.provincia,
      this.distrito,
      this.localCodigoPostal,
      this.localTipoDescripcion,
      this.localCoordenadasGeo,
      this.localCoordenadasLatitud,
      this.localCoordenadasLongitud,
      this.idUsuarioResponsable
      });
}

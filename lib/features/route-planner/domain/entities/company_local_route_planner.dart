import 'package:crm_app/features/companies/domain/entities/company_local.dart';
import 'package:flutter/material.dart';

class CompanyLocalRoutePlanner {
  String id;
  String ruc;
  String localCodigo;
  String localNombre;
  String? razon;
  String? razonComercial;
  String? direccion;
  String? telefono;
  String? email;
  String? tipocliente;
  String? observaciones;
  String? estado;
  String? calificacion;
  String? visibleTodos;
  String? codigoPostal;
  String? idUsuarioRegistro;
  String? clienteNombreEstado;
  String? clienteNombreTipo;
  String? userreportName1;
  String? userreportName;
  String? localDireccion;
  String? localCantidad;
  String? localDistrito;
  String localCoordenadasGeo;
  String localCoordenadasLongitud;
  String localCoordenadasLatitud;
  String? localUbigeoCodigo;
  String? localCodigoPostal;
  String? cchkFechaRegistroCheckIn;
  Key? key;

  CompanyLocalRoutePlanner(
      {required this.id,
      required this.ruc,
      required this.localCodigo,
      required this.localNombre,
      this.razon,
      this.razonComercial,
      this.direccion,
      this.telefono,
      this.email,
      this.tipocliente,
      this.observaciones,
      this.estado,
      this.calificacion,
      this.visibleTodos,
      this.codigoPostal,
      this.idUsuarioRegistro,
      this.clienteNombreEstado,
      this.clienteNombreTipo,
      this.userreportName1,
      this.userreportName,
      this.localDireccion,
      this.localCantidad,
      this.localDistrito,
      required this.localCoordenadasGeo,
      required this.localCoordenadasLongitud,
      required this.localCoordenadasLatitud,
      this.localUbigeoCodigo,
      this.localCodigoPostal,
      this.cchkFechaRegistroCheckIn,
      this.key});

  factory CompanyLocalRoutePlanner.fromJson(Map<String, dynamic> json) =>
      CompanyLocalRoutePlanner(
        ruc: json["EVNT_RUC"],
        localCodigo: json["EVNT_LOCAL_CODIGO"],
        id: '',
        localNombre: '',
        localCoordenadasGeo: '',
        localCoordenadasLongitud: '',
        localCoordenadasLatitud: '',
      );

  Map<String, dynamic> toJson() => {
        "EVNT_RUC": ruc,
        "EVNT_LOCAL_CODIGO": localCodigo,
      };

  /// Refactor after
  static List<CompanyLocalRoutePlanner> convertCompanyLocalList(
      List<CompanyLocal> companyLocalList) {
    return companyLocalList.map((company) {
      return CompanyLocalRoutePlanner(
        id: company.id,
        ruc: company.ruc,
        localCodigo: company.id,
        localNombre: company.localNombre,
        razon: company.razon,
        direccion: company.localDireccion,
        localDireccion: company.localDireccion,
        localDistrito: company.localDistrito,
        localCoordenadasGeo:
            company.localCoordenadasGeo ?? company.coordenadasGeo ?? "",
        localCoordenadasLongitud: company.coordenadasLongitud ?? "",
        localCoordenadasLatitud: company.coordenadasLatitud ?? "",
        codigoPostal: company.localCodigoPostal,
        localUbigeoCodigo: company.ubigeoCodigo,
        localCodigoPostal: company.localCodigoPostal,
        razonComercial: company.localTipoDescripcion,
        telefono: null,
        email: null,
        tipocliente: null,
        observaciones: null,
        estado: null,
        calificacion: null,
        visibleTodos: null,
        idUsuarioRegistro: company.idUsuarioResponsable,
        clienteNombreEstado: null,
        clienteNombreTipo: null,
        userreportName1: null,
        userreportName: null,
        localCantidad: null,
        key: null,
      );
    }).toList();
  }
}

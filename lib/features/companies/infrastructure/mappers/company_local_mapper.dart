import 'package:crm_app/features/companies/domain/domain.dart';


class CompanyLocalMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CompanyLocal(
    id: json['LOCAL_CODIGO'] ?? '',
    localNombre: json['LOCAL_NOMBRE'] ?? '',
    localDireccion: json['LOCAL_DIRECCION'] ?? '',
    localDepartamento: json['LOCAL_DEPARTAMENTO'] ?? '',
    localProvincia: json['LOCAL_PROVINCIA'] ?? '',
    localDistrito: json['LOCAL_DISTRITO'] ?? '',
    localTipo: json['LOCAL_TIPO'] ?? '',
    coordenadasGeo: json['COORDENADAS_GEO'] ?? '',
    coordenadasLongitud: json['COORDENADAS_LONGITUD'] ?? '',
    coordenadasLatitud: json['COORDENADAS_LATITUD'] ?? '',
    departamento: json['DEPARTAMENTO'] ?? '',
    provincia: json['PROVINCIA'] ?? '',
    localTipoDescripcion: json['LOCAL_TIPO_DESCRIPCION'] ?? '',
    distrito: json['DISTRITO'] ?? '', 
    ruc: json['RUC'] ?? '',
  );

}

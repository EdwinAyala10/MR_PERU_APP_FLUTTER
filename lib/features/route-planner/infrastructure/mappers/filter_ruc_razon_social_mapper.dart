import '../../domain/domain.dart';


class FilterRucRazonSocialMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => FilterRucRazonSocial(
    razon: json['RAZON'] ?? '',
    razonComercial: json['RAZON_COMERCIAL'] ?? '',
    ruc: json['RUC'] ?? '',
    direccion: json['DIRECCION'] ?? '',
    email: json['EMAIL'] ?? '',
    localCantidad: json['LOCAL_CANTIDAD'] ?? '',
    localDireccion: json['LOCAL_DIRECCION'] ?? '',
    localDistrito: json['LOCAL_DISTRITO'] ?? '',
    telefono: json['TELEFONO'] ?? '',
    tipoCliente: json['TIPOCLIENTE'] ?? '',
  );

}

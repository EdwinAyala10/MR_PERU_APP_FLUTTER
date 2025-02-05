
class FilterRucRazonSocial {
  String ruc;
  String razon;
  String razonComercial;
  String? direccion;
  String? telefono;
  String? email;
  String? tipoCliente;
  String? localDireccion;
  String? localCantidad;
  String? localDistrito;

  FilterRucRazonSocial({
    required this.ruc,
    required this.razon,
    required this.razonComercial,
    this.direccion,
    this.telefono,
    this.email,
    this.tipoCliente,
    this.localDireccion,
    this.localCantidad,
    this.localDistrito,
  });

}
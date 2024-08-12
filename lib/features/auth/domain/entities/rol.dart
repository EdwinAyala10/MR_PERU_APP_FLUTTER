class Rol {
  final String code;
  final String nombre;

  Rol({required this.code, required this.nombre});

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
    code: json["ROLE_CODE"],
    nombre: json["ROLE_NOMBRE"],
  );

  Map<String, dynamic> toJson() => {
    "ROLE_CODE": code,
    "ROLE_NOMBRE": nombre,
  };
  
}
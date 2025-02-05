class ObjetiveByCategoryResponse {
  String type;
  String icon;
  bool status;
  String message;
  List items;

  ObjetiveByCategoryResponse({
    required this.type,
    required this.icon,
    required this.status,
    required this.message,
    required this.items,
  });

  // Método para crear una instancia de ObjetiveByCategoryResponse desde un JSON
  factory ObjetiveByCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ObjetiveByCategoryResponse(
      type: json['type'] as String,
      icon: json['icon'] as String,
      status: json['status'] as bool,
      message: json['message'] as String,
      items: List<dynamic>.from(
        json['data'],
      ),
    );
  }

  // Método para convertir una instancia de ObjetiveByCategoryResponse a JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'icon': icon,
      'status': status,
      'message': message,
      'data': items,
    };
  }
  
}

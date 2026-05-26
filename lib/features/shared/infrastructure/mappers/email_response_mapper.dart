import 'package:crm_app/features/shared/domain/entities/send_email_response.dart';

class EmailResponseMapper {
  static SendEmailResponse fromJson(Map<String, dynamic> json) {
    // El backend puede retornar dos estructuras:
    // 1. Estructura completa con type, icon, status, message, data
    // 2. Estructura simple con success, message
    
    bool isSuccess = false;
    String message = 'Sin mensaje';
    dynamic data;
    
    // Verificar estructura completa del backend
    if (json.containsKey('status')) {
      isSuccess = json['status'] == true;
      message = json['message']?.toString() ?? 'Sin mensaje';
      data = json['data'];
    } 
    // Estructura alternativa simple
    else if (json.containsKey('success')) {
      isSuccess = json['success'] == true;
      message = json['message']?.toString() ?? 'Sin mensaje';
      data = json['data'];
    }
    
    return SendEmailResponse(
      success: isSuccess,
      message: message,
      data: data,
    );
  }
}

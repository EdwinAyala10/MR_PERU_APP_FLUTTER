import 'package:crm_app/features/shared/domain/entities/send_email_response.dart';

class EmailResponseMapper {
  static SendEmailResponse fromJson(Map<String, dynamic> json) {
    // El backend puede retornar dos estructuras:
    // 1. Estructura completa con type, icon, status, message, data
    // 2. Estructura simple con success, message
    
    bool isSuccess = false;
    String message = 'Sin mensaje';
    
    // Verificar estructura completa del backend
    if (json.containsKey('status')) {
      isSuccess = json['status'] == true;
      message = json['message']?.toString() ?? 'Sin mensaje';
    } 
    // Estructura alternativa simple
    else if (json.containsKey('success')) {
      isSuccess = json['success'] == true;
      message = json['message']?.toString() ?? 'Sin mensaje';
    }
    
    // OPTIMIZACIÓN: NO guardamos el data completo (incluye archivos base64 enormes)
    // Solo necesitamos saber si fue exitoso y el mensaje
    return SendEmailResponse(
      success: isSuccess,
      message: message,
      data: null, // Descartado intencionalmente para mejorar performance
    );
  }
}

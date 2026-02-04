import 'package:flutter/services.dart';

/// TextInputFormatter que limpia números de teléfono pegados.
///
/// Remueve:
/// - Código de país +51
/// - Espacios, guiones, paréntesis y otros caracteres no numéricos
///
/// Ejemplos:
/// - "+51 98745632" → "98745632"
/// - "+51987456321" → "987456321"
/// - "+51 987 654 321" → "987654321"
/// - "987-654-321" → "987654321"
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Obtener el texto nuevo
    String text = newValue.text;

    // Si el texto está vacío, retornar tal cual
    if (text.isEmpty) {
      return newValue;
    }

    // Remover el código de país +51 si está presente
    // Puede estar como "+51", "+ 51", etc.
    text = text.replaceAll(RegExp(r'\+\s*51\s*'), '');

    // Remover todos los caracteres que no sean dígitos
    text = text.replaceAll(RegExp(r'[^\d]'), '');

    // Calcular la nueva posición del cursor
    // Si el texto cambió, colocar el cursor al final
    final int selectionIndex = text.length;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

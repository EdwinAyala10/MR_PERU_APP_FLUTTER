import 'package:flutter/material.dart';
import 'package:crm_app/config/theme/app_theme.dart';

/// Selector de color profesional tipo Word/Gmail/Canva
/// Muestra colores en cuadrícula visual con círculos seleccionables
class ProfessionalColorPicker extends StatelessWidget {
  final Color? currentColor;
  final ValueChanged<Color> onColorSelected;
  final bool isBackground;

  const ProfessionalColorPicker({
    super.key,
    this.currentColor,
    required this.onColorSelected,
    this.isBackground = false,
  });

  // Paleta de colores profesional organizada por tonos
  static const List<List<Color>> _colorPalette = [
    // Fila 1: Negros y grises
    [
      Color(0xFF000000), // Negro
      Color(0xFF434343), // Gris oscuro
      Color(0xFF666666), // Gris medio
      Color(0xFF999999), // Gris
      Color(0xFFB7B7B7), // Gris claro
      Color(0xFFCCCCCC), // Gris más claro
      Color(0xFFD9D9D9), // Gris muy claro
      Color(0xFFEFEFEF), // Casi blanco
      Color(0xFFF3F3F3), // Blanco grisáceo
      Color(0xFFFFFFFF), // Blanco
    ],
    
    // Fila 2: Rojos
    [
      Color(0xFF980000), // Rojo oscuro
      Color(0xFFFF0000), // Rojo
      Color(0xFFFF9900), // Naranja-rojo
      Color(0xFFFFFF00), // Amarillo
      Color(0xFF00FF00), // Verde lima
      Color(0xFF00FFFF), // Cian
      Color(0xFF4A86E8), // Azul claro
      Color(0xFF0000FF), // Azul
      Color(0xFF9900FF), // Violeta
      Color(0xFFFF00FF), // Magenta
    ],
    
    // Fila 3: Rojos claros
    [
      Color(0xFFE6B8AF), // Rosa pálido
      Color(0xFFF4CCCC), // Rosa claro
      Color(0xFFFCE5CD), // Naranja claro
      Color(0xFFFFF2CC), // Amarillo claro
      Color(0xFFD9EAD3), // Verde claro
      Color(0xFFD0E0E3), // Azul agua claro
      Color(0xFFC9DAF8), // Azul cielo
      Color(0xFFCFE2F3), // Azul claro
      Color(0xFFD9D2E9), // Lavanda
      Color(0xFFEAD1DC), // Rosa-violeta claro
    ],
    
    // Fila 4: Tonos medios
    [
      Color(0xFFDD7E6B), // Rojo salmón
      Color(0xFFEA9999), // Rosa medio
      Color(0xFFF9CB9C), // Naranja claro
      Color(0xFFFFE599), // Amarillo medio
      Color(0xFFB6D7A8), // Verde claro
      Color(0xFFA2C4C9), // Azul agua medio
      Color(0xFF9FC5E8), // Azul medio
      Color(0xFF6FA8DC), // Azul
      Color(0xFFB4A7D6), // Lavanda medio
      Color(0xFFD5A6BD), // Rosa-violeta
    ],
    
    // Fila 5: Tonos intensos
    [
      Color(0xFFCC4125), // Rojo
      Color(0xFFE06666), // Rojo brillante
      Color(0xFFF6B26B), // Naranja
      Color(0xFFFFD966), // Amarillo dorado
      Color(0xFF93C47D), // Verde
      Color(0xFF76A5AF), // Azul agua
      Color(0xFF6D9EEB), // Azul brillante
      Color(0xFF3D85C6), // Azul intenso
      Color(0xFF8E7CC3), // Púrpura
      Color(0xFFC27BA0), // Rosa intenso
    ],
    
    // Fila 6: Tonos oscuros
    [
      Color(0xFFA61C00), // Rojo oscuro
      Color(0xFFCC0000), // Rojo fuerte
      Color(0xFFE69138), // Naranja oscuro
      Color(0xFFF1C232), // Amarillo oscuro
      Color(0xFF6AA84F), // Verde oscuro
      Color(0xFF45818E), // Azul agua oscuro
      Color(0xFF3C78D8), // Azul oscuro
      Color(0xFF1155CC), // Azul profundo
      Color(0xFF674EA7), // Púrpura oscuro
      Color(0xFFA64D79), // Rosa oscuro
    ],
    
    // Fila 7: Tonos muy oscuros
    [
      Color(0xFF85200C), // Marrón rojizo
      Color(0xFF990000), // Rojo muy oscuro
      Color(0xFFB45F06), // Naranja oscuro
      Color(0xFFBF9000), // Dorado oscuro
      Color(0xFF38761D), // Verde oscuro
      Color(0xFF134F5C), // Verde azulado
      Color(0xFF1C4587), // Azul marino
      Color(0xFF0B5394), // Azul oscuro
      Color(0xFF351C75), // Púrpura muy oscuro
      Color(0xFF741B47), // Magenta oscuro
    ],
    
    // Fila 8: Colores corporativos
    [
      Color(0xFF00A8DD), // Primary color (Azul empresa)
      Color(0xFF00607D), // Secondary color (Azul oscuro empresa)
      Color(0xFF1A73E8), // Azul Google
      Color(0xFF34A853), // Verde Google
      Color(0xFFFBBC04), // Amarillo Google
      Color(0xFFEA4335), // Rojo Google
      Color(0xFF5F6368), // Gris Google
      Color(0xFF00BCD4), // Cian Material
      Color(0xFF9C27B0), // Púrpura Material
      Color(0xFFFF5722), // Naranja Material
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Calcular tamaño máximo del diálogo basado en el tamaño de pantalla
    final maxDialogHeight = screenHeight * 0.85; // 85% de la altura
    final maxDialogWidth = screenWidth > 450 ? 420.0 : screenWidth * 0.92; // 92% del ancho en móviles
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fijo arriba)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: secondaryColor.withValues(alpha: 0.2), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isBackground ? 'Color de fondo' : 'Color de texto',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Paleta de colores con scroll
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 360 ? 12.0 : 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _colorPalette.map((row) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: screenWidth < 360 ? 8.0 : 12.0,
                      ),
                      child: Wrap(
                        spacing: screenWidth < 360 ? 6.0 : 8.0,
                        runSpacing: screenWidth < 360 ? 6.0 : 8.0,
                        alignment: WrapAlignment.center,
                        children: row.map((color) {
                          final isSelected = currentColor == color;
                          return _buildColorCircle(context, color, isSelected);
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Botón inferior (fijo abajo)
            if (isBackground)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: secondaryColor.withValues(alpha: 0.2), width: 1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      onColorSelected(Colors.transparent);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.format_color_reset, size: 18, color: primaryColor),
                    label: Text('Sin color de fondo', style: TextStyle(color: secondaryColor)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(BuildContext context, Color color, bool isSelected) {
    final isWhite = color == Colors.white || color.computeLuminance() > 0.9;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Tamaño adaptativo según el ancho de pantalla
    final circleSize = screenWidth < 360 ? 28.0 : 32.0;
    final iconSize = screenWidth < 360 ? 14.0 : 18.0;
    
    return InkWell(
      onTap: () {
        onColorSelected(color);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(circleSize / 2),
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected 
                ? primaryColor 
                : (isWhite ? secondaryColor.withValues(alpha: 0.2) : Colors.transparent),
            width: isSelected ? 2.5 : (isWhite ? 1 : 0),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: iconSize,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              )
            : null,
      ),
    );
  }
}

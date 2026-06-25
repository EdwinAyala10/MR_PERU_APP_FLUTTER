import 'package:flutter/material.dart';

/// Entity que representa el formato de texto en el editor
class TextFormat {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final TextAlignment alignment;
  final Color textColor;
  final double fontSize;

  const TextFormat({
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.alignment = TextAlignment.left,
    this.textColor = Colors.black,
    this.fontSize = 14.0,
  });

  TextFormat copyWith({
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    bool? isStrikethrough,
    TextAlignment? alignment,
    Color? textColor,
    double? fontSize,
  }) {
    return TextFormat(
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      alignment: alignment ?? this.alignment,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  /// Convierte texto plano a HTML con el formato aplicado
  String toHtml(String text) {
    if (text.isEmpty) return '';
    
    // Estilos CSS
    final alignmentStyle = 'text-align: ${alignment.toCss()};';
    final fontSizeStyle = 'font-size: ${fontSize}px;';
    final colorStyle = 'color: #${textColor.value.toRadixString(16).padLeft(8, '0').substring(2)};';
    
    final style = '$alignmentStyle $fontSizeStyle $colorStyle';
    
    // Construir HTML
    String html = '<p style="$style">';
    
    if (isBold) html += '<b>';
    if (isItalic) html += '<i>';
    if (isUnderline) html += '<u>';
    if (isStrikethrough) html += '<strike>';
    
    html += text;
    
    if (isStrikethrough) html += '</strike>';
    if (isUnderline) html += '</u>';
    if (isItalic) html += '</i>';
    if (isBold) html += '</b>';
    
    html += '</p>';
    
    return html;
  }

  /// Obtiene la decoración de texto para Flutter
  TextDecoration getTextDecoration() {
    List<TextDecoration> decorations = [];
    if (isUnderline) decorations.add(TextDecoration.underline);
    if (isStrikethrough) decorations.add(TextDecoration.lineThrough);
    
    if (decorations.isEmpty) return TextDecoration.none;
    if (decorations.length == 1) return decorations[0];
    return TextDecoration.combine(decorations);
  }

  /// Obtiene el TextAlign para Flutter
  TextAlign getTextAlign() {
    return alignment.toTextAlign();
  }
}

/// Enum para la alineación de texto
enum TextAlignment {
  left,
  center,
  right,
  justify;

  String toCss() {
    switch (this) {
      case TextAlignment.left:
        return 'left';
      case TextAlignment.center:
        return 'center';
      case TextAlignment.right:
        return 'right';
      case TextAlignment.justify:
        return 'justify';
    }
  }

  TextAlign toTextAlign() {
    switch (this) {
      case TextAlignment.left:
        return TextAlign.left;
      case TextAlignment.center:
        return TextAlign.center;
      case TextAlignment.right:
        return TextAlign.right;
      case TextAlignment.justify:
        return TextAlign.justify;
    }
  }
}

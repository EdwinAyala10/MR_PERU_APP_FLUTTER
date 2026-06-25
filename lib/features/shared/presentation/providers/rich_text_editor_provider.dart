import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/shared/domain/entities/text_format.dart';

/// Estado del editor de texto enriquecido
class RichTextEditorState {
  final TextFormat format;
  final String htmlContent;

  const RichTextEditorState({
    required this.format,
    required this.htmlContent,
  });

  RichTextEditorState copyWith({
    TextFormat? format,
    String? htmlContent,
  }) {
    return RichTextEditorState(
      format: format ?? this.format,
      htmlContent: htmlContent ?? this.htmlContent,
    );
  }
}

/// Notifier para manejar el estado del editor
class RichTextEditorNotifier extends StateNotifier<RichTextEditorState> {
  RichTextEditorNotifier()
      : super(const RichTextEditorState(
          format: TextFormat(),
          htmlContent: '',
        ));

  /// Actualiza el contenido HTML basado en el texto actual
  void updateContent(String text) {
    final html = state.format.toHtml(text);
    state = state.copyWith(htmlContent: html);
  }

  /// Alterna negrita
  void toggleBold() {
    state = state.copyWith(
      format: state.format.copyWith(isBold: !state.format.isBold),
    );
  }

  /// Alterna cursiva
  void toggleItalic() {
    state = state.copyWith(
      format: state.format.copyWith(isItalic: !state.format.isItalic),
    );
  }

  /// Alterna subrayado
  void toggleUnderline() {
    state = state.copyWith(
      format: state.format.copyWith(isUnderline: !state.format.isUnderline),
    );
  }

  /// Alterna tachado
  void toggleStrikethrough() {
    state = state.copyWith(
      format: state.format.copyWith(isStrikethrough: !state.format.isStrikethrough),
    );
  }

  /// Cambia la alineación
  void setAlignment(TextAlignment alignment) {
    state = state.copyWith(
      format: state.format.copyWith(alignment: alignment),
    );
  }

  /// Cambia el color del texto
  void setTextColor(Color color) {
    state = state.copyWith(
      format: state.format.copyWith(textColor: color),
    );
  }

  /// Cambia el tamaño de fuente
  void setFontSize(double size) {
    state = state.copyWith(
      format: state.format.copyWith(fontSize: size),
    );
  }

  /// Resetea el formato a valores por defecto
  void resetFormat() {
    state = state.copyWith(format: const TextFormat());
  }
}

/// Provider del estado del editor
final richTextEditorProvider = StateNotifierProvider.autoDispose<RichTextEditorNotifier, RichTextEditorState>((ref) {
  return RichTextEditorNotifier();
});

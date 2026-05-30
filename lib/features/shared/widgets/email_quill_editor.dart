import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:crm_app/features/shared/widgets/professional_color_picker.dart';
import 'package:crm_app/config/theme/app_theme.dart';

/// Editor profesional de correo electrónico tipo Gmail/Word
/// Soporta formato por selección de texto
class EmailQuillEditor extends StatefulWidget {
  final Function(String html) onContentChanged;
  final String? initialContent;
  
  const EmailQuillEditor({
    super.key,
    required this.onContentChanged,
    this.initialContent,
  });

  @override
  State<EmailQuillEditor> createState() => _EmailQuillEditorState();
}

class _EmailQuillEditorState extends State<EmailQuillEditor> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador con contenido vacío o inicial
    _controller = quill.QuillController.basic();
    
    // Escuchar cambios en el documento
    _controller.document.changes.listen((event) {
      _onContentChanged();
    });
    
    // Escuchar cambios en la selección para actualizar estados de botones
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onContentChanged() {
    try {
      // Convertir Delta a HTML
      final delta = _controller.document.toDelta();
      final converter = QuillDeltaToHtmlConverter(
        delta.toJson(),
        ConverterOptions.forEmail(),
      );
      final html = converter.convert();
      
      // Notificar cambio
      widget.onContentChanged(html);
    } catch (e) {
      debugPrint('Error converting to HTML: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título de la sección
        _buildSectionHeader(),
        
        // Toolbar horizontal moderna y scrollable
        _buildModernToolbar(),
        
        // Editor con scroll vertical (ocupa el espacio disponible)
        Expanded(
          child: _buildEditor(),
        ),
      ],
    );
  }

  /// Header de la sección
  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 18,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            'Cuerpo del correo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Toolbar moderna horizontal con scroll lateral
  Widget _buildModernToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Deshacer / Rehacer
            _buildToolbarButton(
              icon: Icons.undo_rounded,
              tooltip: 'Deshacer',
              onPressed: () => _controller.undo(),
            ),
            _buildToolbarButton(
              icon: Icons.redo_rounded,
              tooltip: 'Rehacer',
              onPressed: () => _controller.redo(),
            ),
            
            _buildDivider(),
            
            // Formato de texto
            _buildToggleButton(
              icon: Icons.format_bold_rounded,
              tooltip: 'Negrita',
              attribute: quill.Attribute.bold,
            ),
            _buildToggleButton(
              icon: Icons.format_italic_rounded,
              tooltip: 'Cursiva',
              attribute: quill.Attribute.italic,
            ),
            _buildToggleButton(
              icon: Icons.format_underlined_rounded,
              tooltip: 'Subrayado',
              attribute: quill.Attribute.underline,
            ),
            _buildToggleButton(
              icon: Icons.strikethrough_s_rounded,
              tooltip: 'Tachado',
              attribute: quill.Attribute.strikeThrough,
            ),
            
            _buildDivider(),
            
            // Color de texto y fondo (con picker profesional)
            _buildColorButton(
              icon: Icons.format_color_text_rounded,
              tooltip: 'Color de texto',
              isBackground: false,
            ),
            _buildColorButton(
              icon: Icons.format_color_fill_rounded,
              tooltip: 'Color de fondo',
              isBackground: true,
            ),
            
            _buildDivider(),
            
            // Alineación
            _buildToggleButton(
              icon: Icons.format_align_left_rounded,
              tooltip: 'Alinear izquierda',
              attribute: quill.Attribute.leftAlignment,
            ),
            _buildToggleButton(
              icon: Icons.format_align_center_rounded,
              tooltip: 'Centrar',
              attribute: quill.Attribute.centerAlignment,
            ),
            _buildToggleButton(
              icon: Icons.format_align_right_rounded,
              tooltip: 'Alinear derecha',
              attribute: quill.Attribute.rightAlignment,
            ),
            _buildToggleButton(
              icon: Icons.format_align_justify_rounded,
              tooltip: 'Justificar',
              attribute: quill.Attribute.justifyAlignment,
            ),
            
            _buildDivider(),
            
            // Listas
            _buildToggleButton(
              icon: Icons.format_list_bulleted_rounded,
              tooltip: 'Lista con viñetas',
              attribute: quill.Attribute.ul,
            ),
            _buildToggleButton(
              icon: Icons.format_list_numbered_rounded,
              tooltip: 'Lista numerada',
              attribute: quill.Attribute.ol,
            ),
            _buildToolbarButton(
              icon: Icons.checklist_rounded,
              tooltip: 'Lista de verificación',
              onPressed: () {
                final attribute = _controller.getSelectionStyle().attributes[quill.Attribute.list.key];
                if (attribute == quill.Attribute.unchecked || attribute == quill.Attribute.checked) {
                  _controller.formatSelection(quill.Attribute.clone(quill.Attribute.unchecked, null));
                } else {
                  _controller.formatSelection(quill.Attribute.unchecked);
                }
              },
            ),
            
            _buildDivider(),
            
            // Sangría
            _buildToolbarButton(
              icon: Icons.format_indent_decrease_rounded,
              tooltip: 'Reducir sangría',
              onPressed: () {
                _controller.indentSelection(false);
              },
            ),
            _buildToolbarButton(
              icon: Icons.format_indent_increase_rounded,
              tooltip: 'Aumentar sangría',
              onPressed: () {
                _controller.indentSelection(true);
              },
            ),
            
            _buildDivider(),
            
            // Citas y código
            _buildToggleButton(
              icon: Icons.format_quote_rounded,
              tooltip: 'Cita',
              attribute: quill.Attribute.blockQuote,
            ),
            _buildToggleButton(
              icon: Icons.code_rounded,
              tooltip: 'Bloque de código',
              attribute: quill.Attribute.codeBlock,
            ),
            
            _buildDivider(),
            
            // Enlaces
            _buildToolbarButton(
              icon: Icons.link_rounded,
              tooltip: 'Insertar enlace',
              onPressed: () => _showLinkDialog(),
            ),
            
            _buildDivider(),
            
            // Limpiar formato
            _buildToolbarButton(
              icon: Icons.format_clear_rounded,
              tooltip: 'Limpiar formato',
              onPressed: () {
                _controller.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
                _controller.formatSelection(quill.Attribute.clone(quill.Attribute.italic, null));
                _controller.formatSelection(quill.Attribute.clone(quill.Attribute.underline, null));
                _controller.formatSelection(quill.Attribute.clone(quill.Attribute.strikeThrough, null));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String tooltip,
    required quill.Attribute attribute,
  }) {
    final isActive = _controller.getSelectionStyle().attributes[attribute.key] == attribute;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _controller.formatSelection(
              isActive ? quill.Attribute.clone(attribute, null) : attribute,
            );
            setState(() {}); // Refrescar para mostrar estado activo
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.black87
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? Colors.black87 : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton({
    required IconData icon,
    required String tooltip,
    required bool isBackground,
  }) {
    // Obtener el color actual de la selección
    final attributes = _controller.getSelectionStyle().attributes;
    Color? currentColor;
    
    if (isBackground) {
      final bgAttr = attributes[quill.Attribute.background.key];
      if (bgAttr != null && bgAttr.value != null) {
        try {
          final colorStr = bgAttr.value.toString().replaceAll('#', '');
          currentColor = Color(int.parse('FF$colorStr', radix: 16));
        } catch (e) {
          currentColor = null;
        }
      }
    } else {
      final colorAttr = attributes[quill.Attribute.color.key];
      if (colorAttr != null && colorAttr.value != null) {
        try {
          final colorStr = colorAttr.value.toString().replaceAll('#', '');
          currentColor = Color(int.parse('FF$colorStr', radix: 16));
        } catch (e) {
          currentColor = null;
        }
      }
    }
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showColorPicker(isBackground),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Colors.black87,
                ),
                const SizedBox(height: 2),
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: currentColor ?? Colors.black87,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 1,
      height: 28,
      color: Colors.grey.shade300,
    );
  }

  /// Mostrar selector de color profesional
  void _showColorPicker(bool isBackground) {
    showDialog(
      context: context,
      builder: (context) => ProfessionalColorPicker(
        currentColor: null,
        isBackground: isBackground,
        onColorSelected: (color) {
          if (isBackground) {
            _controller.formatSelection(
              color == Colors.transparent
                  ? quill.Attribute.clone(quill.Attribute.background, null)
                  : quill.BackgroundAttribute('#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}'),
            );
          } else {
            _controller.formatSelection(
              quill.ColorAttribute('#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}'),
            );
          }
          setState(() {});
        },
      ),
    );
  }

  /// Mostrar diálogo para insertar enlace
  void _showLinkDialog() {
    final textController = TextEditingController();
    final urlController = TextEditingController();
    
    // Si hay texto seleccionado, usarlo como texto del enlace
    final selection = _controller.selection;
    if (!selection.isCollapsed) {
      final length = selection.end - selection.start;
      textController.text = _controller.document.toPlainText().substring(selection.start, selection.start + length);
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Insertar enlace',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Texto del enlace',
                labelStyle: TextStyle(color: Colors.grey.shade700),
                hintText: 'Ej: Haga clic aquí',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'URL',
                labelStyle: TextStyle(color: Colors.grey.shade700),
                hintText: 'https://ejemplo.com',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade700)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = textController.text.trim();
              final url = urlController.text.trim();
              
              if (text.isNotEmpty && url.isNotEmpty) {
                _controller.formatText(
                  selection.start,
                  text.length,
                  quill.LinkAttribute(url),
                );
                if (selection.isCollapsed) {
                  _controller.document.insert(selection.start, text);
                }
              }
              
              Navigator.pop(context);
            },
            child: const Text('Insertar'),
          ),
        ],
      ),
    );
  }

  /// Editor con scroll vertical fluido
  Widget _buildEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: quill.QuillEditor(
        scrollController: _scrollController,
        focusNode: _focusNode,
        configurations: quill.QuillEditorConfigurations(
          controller: _controller,
          placeholder: 'Escribe el contenido del correo aquí...',
          padding: const EdgeInsets.all(16),
          autoFocus: false,
          expands: false,
          scrollable: true,
          customStyles: quill.DefaultStyles(
            paragraph: quill.DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
              const quill.VerticalSpacing(8, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
            placeHolder: quill.DefaultTextBlockStyle(
              TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
              const quill.VerticalSpacing(8, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
          ),
        ),
      ),
    );
  }


}

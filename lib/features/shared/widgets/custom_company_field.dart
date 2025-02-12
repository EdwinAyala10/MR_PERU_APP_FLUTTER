import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomCompanyField extends StatefulWidget {
  final bool isTopField;
  final bool isBottomField;
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final int maxLines;
  final TextEditingController? controller;
  final bool? enabled;
  final bool readOnly; // Nuevo parámetro para el campo de solo lectura
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String? initialValue;
  final int? maxLength; // Nuevo parámetro para el límite de caracteres

  const CustomCompanyField({
    Key? key,
    this.isTopField = false,
    this.isBottomField = false,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.controller,
    this.enabled = true,
    this.readOnly = false, // Valor predeterminado para el campo de solo lectura
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.initialValue,
    this.maxLength, // Incluir el nuevo parámetro
  }) : super(key: key);

  @override
  _CustomCompanyFieldState createState() => _CustomCompanyFieldState();
}

class _CustomCompanyFieldState extends State<CustomCompanyField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalController.text = widget.initialValue ?? ''; // Usar el valor inicial si está disponible
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black45),
      borderRadius: BorderRadius.circular(8),
    );

    return Column(
      children: [
        const SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            color: widget.readOnly ? Colors.grey[200] : Colors.white, // Cambiar color de fondo cuando es readonly
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (widget.isBottomField)
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
            ],
          ),
          child: TextFormField(
            controller: _internalController,
            textCapitalization: widget.textCapitalization!,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            validator: widget.validator,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly, // Establecer el campo de solo lectura
            keyboardType: widget.keyboardType,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            maxLines: widget.maxLines,
            inputFormatters: widget.maxLength != null
                ? [LengthLimitingTextInputFormatter(widget.maxLength)]
                : null, // Agregar el limitador de caracteres
            decoration: InputDecoration(
              border: border,
              floatingLabelBehavior: widget.maxLines > 1
                  ? FloatingLabelBehavior.always
                  : FloatingLabelBehavior.auto,
              floatingLabelStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              errorBorder: border.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: border.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              labelText: widget.label,
              hintText: widget.hint,
              errorText: widget.errorMessage,
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              suffixIcon: widget.errorMessage != null
                  ? const Icon(Icons.error, color: Colors.red)
                  : null,
            ),
          ),
        ),
        const SizedBox(
          height: 6.0,
        )
      ],
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }
}
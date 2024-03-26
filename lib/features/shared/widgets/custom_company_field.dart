import 'package:flutter/material.dart';

class CustomCompanyField extends StatelessWidget {
  final bool isTopField; // La idea es que tenga bordes redondeados arriba
  final bool isBottomField; // La idea es que tenga bordes redondeados abajo
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String initialValue;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool? enabled;

  const CustomCompanyField({
    Key? key,
    this.isTopField = false,
    this.isBottomField = false,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.initialValue = '',
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(8),
    );

    return Column(
      children: [
        SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: isTopField ? Radius.circular(8) : Radius.zero,
              bottom: isBottomField ? Radius.circular(8) : Radius.zero,
            ),
            boxShadow: [
              if (isBottomField)
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
            ],
          ),
          child: TextFormField(
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            validator: validator,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            maxLines: maxLines,
            initialValue: initialValue,
            decoration: InputDecoration(
              border: border,
              floatingLabelBehavior: maxLines > 1
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
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              labelText: label,
              hintText: hint,
              errorText: errorMessage,
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              suffixIcon: errorMessage != null
                  ? const Icon(Icons.error, color: Colors.red)
                  : null,
            ),
          ),
        ),
        SizedBox(
          height: 6.0,
        )
      ],
    );
  }
}

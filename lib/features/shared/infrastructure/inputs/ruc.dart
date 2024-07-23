import 'package:formz/formz.dart';

// Define input validation errors
enum RucError { empty, invalidLength, nonNumeric }

// Extend FormzInput and provide the input type and error type.
class Ruc extends FormzInput<String, RucError> {

  // Call super.pure to represent an unmodified form input.
  const Ruc.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Ruc.dirty(String value) : super.dirty(value);

  // Provide error message based on the error type.
  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == RucError.empty) return 'El campo es requerido';
    if (displayError == RucError.invalidLength) return 'El campo debe contener exactamente 11 dígitos';
    if (displayError == RucError.nonNumeric) return 'El campo debe contener solo números';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  RucError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return RucError.empty;
    if (value.length != 11) return RucError.invalidLength;
    if (!RegExp(r'^\d{11}$').hasMatch(value)) return RucError.nonNumeric;

    return null;
  }
}

import 'package:formz/formz.dart';

// Define input validation errors
enum EntornoError { empty, format }

// Extend FormzInput and provide the input type and error type.
class Entorno extends FormzInput<String, EntornoError> {

  // Call super.pure to represent an unmodified form input.
  const Entorno.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Entorno.dirty( String value ) : super.dirty(value);

  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == EntornoError.empty ) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  EntornoError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return EntornoError.empty;

    return null;
  }
}
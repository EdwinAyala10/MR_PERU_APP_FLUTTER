import 'package:formz/formz.dart';

// Define input validation errors
enum InputPeriodicidadError { empty }

// Extend FormzInput and provide the input type and error type.
class InputPeriodicidad extends FormzInput<String, InputPeriodicidadError> {


  // Call super.pure to represent an unmodified form input.
  const InputPeriodicidad.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const InputPeriodicidad.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == InputPeriodicidadError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  InputPeriodicidadError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return InputPeriodicidadError.empty;

    return null;
  }
}
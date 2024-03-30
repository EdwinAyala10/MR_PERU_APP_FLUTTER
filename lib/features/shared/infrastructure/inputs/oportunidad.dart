import 'package:formz/formz.dart';

// Define input validation errors
enum OportunidadError { empty }

// Extend FormzInput and provide the input type and error type.
class Oportunidad extends FormzInput<String, OportunidadError> {


  // Call super.pure to represent an unmodified form input.
  const Oportunidad.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Oportunidad.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == OportunidadError.empty ) return 'Es requerido seleccionar una oportunidad';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  OportunidadError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return OportunidadError.empty;

    return null;
  }
}
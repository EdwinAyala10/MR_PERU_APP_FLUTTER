import 'package:formz/formz.dart';

// Define input validation errors
enum RazonError { empty }

// Extend FormzInput and provide the input type and error type.
class Razon extends FormzInput<String, RazonError> {


  // Call super.pure to represent an unmodified form input.
  const Razon.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Razon.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == RazonError.empty ) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  RazonError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return RazonError.empty;

    return null;
  }
}
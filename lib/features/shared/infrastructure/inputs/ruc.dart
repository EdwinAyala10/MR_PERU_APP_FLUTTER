import 'package:formz/formz.dart';

// Define input validation errors
enum RucError { empty }

// Extend FormzInput and provide the input type and error type.
class Ruc extends FormzInput<String, RucError> {


  // Call super.pure to represent an unmodified form input.
  const Ruc.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Ruc.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == RucError.empty ) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  RucError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return RucError.empty;

    return null;
  }
}
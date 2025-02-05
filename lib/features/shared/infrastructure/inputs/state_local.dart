import 'package:formz/formz.dart';

// Define input validation errors
enum StateLocalError { empty }

// Extend FormzInput and provide the input type and error type.
class StateLocal extends FormzInput<String, StateLocalError> {


  // Call super.pure to represent an unmodified form input.
  const StateLocal.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const StateLocal.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == StateLocalError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  StateLocalError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return StateLocalError.empty;

    return null;
  }
}
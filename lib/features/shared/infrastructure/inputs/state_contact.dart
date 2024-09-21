import 'package:formz/formz.dart';

// Define input validation errors
enum StateContactError { empty }

// Extend FormzInput and provide the input type and error type.
class StateContact extends FormzInput<String, StateContactError> {


  // Call super.pure to represent an unmodified form input.
  const StateContact.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const StateContact.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == StateContactError.empty ) return 'Es requerido, debe seleccionar un contacto';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  StateContactError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return StateContactError.empty;

    return null;
  }
}
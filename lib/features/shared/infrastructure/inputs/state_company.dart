import 'package:formz/formz.dart';

// Define input validation errors
enum StateCompanyError { empty }

// Extend FormzInput and provide the input type and error type.
class StateCompany extends FormzInput<String, StateCompanyError> {


  // Call super.pure to represent an unmodified form input.
  const StateCompany.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const StateCompany.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == StateCompanyError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  StateCompanyError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return StateCompanyError.empty;

    return null;
  }
}
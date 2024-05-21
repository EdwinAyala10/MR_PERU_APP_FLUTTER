import 'package:formz/formz.dart';

// Define input validation errors
enum StateOpportunityError { empty }

// Extend FormzInput and provide the input type and error type.
class StateOpportunity extends FormzInput<String, StateOpportunityError> {


  // Call super.pure to represent an unmodified form input.
  const StateOpportunity.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const StateOpportunity.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == StateOpportunityError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  StateOpportunityError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return StateOpportunityError.empty;

    return null;
  }
}
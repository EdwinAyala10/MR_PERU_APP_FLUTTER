import 'package:formz/formz.dart';

// Define input validation errors
enum EmpresaPrincipalError { empty }

// Extend FormzInput and provide the input type and error type.
class EmpresaPrincipal extends FormzInput<String, EmpresaPrincipalError> {


  // Call super.pure to represent an unmodified form input.
  const EmpresaPrincipal.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const EmpresaPrincipal.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == EmpresaPrincipalError.empty ) return 'Seleccione una empresa principal';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  EmpresaPrincipalError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return EmpresaPrincipalError.empty;

    return null;
  }
}
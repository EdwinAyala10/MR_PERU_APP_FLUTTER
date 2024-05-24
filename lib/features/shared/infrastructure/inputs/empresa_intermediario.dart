import 'package:formz/formz.dart';

// Define input validation errors
enum EmpresaIntermediarioError { empty }

// Extend FormzInput and provide the input type and error type.
class EmpresaIntermediario extends FormzInput<String, EmpresaIntermediarioError> {


  // Call super.pure to represent an unmodified form input.
  const EmpresaIntermediario.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const EmpresaIntermediario.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == EmpresaIntermediarioError.empty ) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  EmpresaIntermediarioError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return EmpresaIntermediarioError.empty;

    return null;
  }
}
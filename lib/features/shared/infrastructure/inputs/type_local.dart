import 'package:formz/formz.dart';

// Define input validation errors
enum TypeLocalError { empty }

// Extend FormzInput and provide the input type and error type.
class TypeLocal extends FormzInput<String, TypeLocalError> {


  // Call super.pure to represent an unmodified form input.
  const TypeLocal.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const TypeLocal.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == TypeLocalError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  TypeLocalError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return TypeLocalError.empty;

    return null;
  }
}
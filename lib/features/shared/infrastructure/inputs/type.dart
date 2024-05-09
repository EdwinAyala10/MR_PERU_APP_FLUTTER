import 'package:formz/formz.dart';

// Define input validation errors
enum TypeError { empty }

// Extend FormzInput and provide the input type and error type.
class Type extends FormzInput<String, TypeError> {


  // Call super.pure to represent an unmodified form input.
  const Type.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Type.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == TypeError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  TypeError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return TypeError.empty;

    return null;
  }
}
import 'package:formz/formz.dart';

// Define input validation errors
enum CalificationError { empty }

// Extend FormzInput and provide the input type and error type.
class Calification extends FormzInput<String, CalificationError> {


  // Call super.pure to represent an unmodified form input.
  const Calification.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Calification.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == CalificationError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  CalificationError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return CalificationError.empty;

    return null;
  }
}
import 'package:formz/formz.dart';

// Define input validation errors
enum RubroError { empty }

// Extend FormzInput and provide the input type and error type.
class Rubro extends FormzInput<String, RubroError> {


  // Call super.pure to represent an unmodified form input.
  const Rubro.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Rubro.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == RubroError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  RubroError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return RubroError.empty;

    return null;
  }
}
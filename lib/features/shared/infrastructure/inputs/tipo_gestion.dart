import 'package:formz/formz.dart';

// Define input validation errors
enum TipoGestionError { empty }

// Extend FormzInput and provide the input type and error type.
class TipoGestion extends FormzInput<String, TipoGestionError> {


  // Call super.pure to represent an unmodified form input.
  const TipoGestion.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const TipoGestion.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == TipoGestionError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  TipoGestionError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return TipoGestionError.empty;

    return null;
  }
}
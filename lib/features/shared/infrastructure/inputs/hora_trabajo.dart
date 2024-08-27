import 'package:formz/formz.dart';

// Define input validation errors
enum HoraTrabajoError { empty }

// Extend FormzInput and provide the input type and error type.
class HoraTrabajo extends FormzInput<String, HoraTrabajoError> {


  // Call super.pure to represent an unmodified form input.
  const HoraTrabajo.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const HoraTrabajo.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == HoraTrabajoError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  HoraTrabajoError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return HoraTrabajoError.empty;

    return null;
  }
}
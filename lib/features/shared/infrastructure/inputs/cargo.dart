import 'package:formz/formz.dart';

// Define input validation errors
enum CargoError { empty }

// Extend FormzInput and provide the input type and error type.
class Cargo extends FormzInput<String, CargoError> {


  // Call super.pure to represent an unmodified form input.
  const Cargo.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Cargo.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == CargoError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  CargoError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return CargoError.empty;

    return null;
  }
}
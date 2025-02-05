import 'package:formz/formz.dart';

// Define input validation errors
enum ContactoError { empty }

// Extend FormzInput and provide the input type and error type.
class Contacto extends FormzInput<String, ContactoError> {


  // Call super.pure to represent an unmodified form input.
  const Contacto.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Contacto.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == ContactoError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  ContactoError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return ContactoError.empty;

    return null;
  }
}
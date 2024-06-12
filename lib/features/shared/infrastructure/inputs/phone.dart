import 'package:formz/formz.dart';

// Define input validation errors
enum PhoneError { empty, invalidLength }

// Extend FormzInput and provide the input type and error type.
class Phone extends FormzInput<String, PhoneError> {


  // Call super.pure to represent an unmodified form input.
  const Phone.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Phone.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == PhoneError.empty ) return 'El campo es requerido';
    if (displayError == PhoneError.invalidLength) return 'El campo debe tener 9 dígitos';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  PhoneError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return PhoneError.empty;
    if (value.length != 9) return PhoneError.invalidLength;

    return null;
  }
}
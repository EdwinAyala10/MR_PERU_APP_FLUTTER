import 'package:formz/formz.dart';

// Define input validation errors
enum AddressError { empty }

// Extend FormzInput and provide the input type and error type.
class Address extends FormzInput<String, AddressError> {


  // Call super.pure to represent an unmodified form input.
  const Address.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Address.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == AddressError.empty ) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  AddressError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return AddressError.empty;

    return null;
  }
}
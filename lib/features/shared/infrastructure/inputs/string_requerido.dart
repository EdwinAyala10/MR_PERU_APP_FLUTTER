import 'package:formz/formz.dart';

// Define input validation errors
enum StringRequeridoError { empty }

// Extend FormzInput and provide the input type and error type.
class StringRequerido extends FormzInput<String, StringRequeridoError> {


  // Call super.pure to represent an unmodified form input.
  const StringRequerido.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const StringRequerido.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == StringRequeridoError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  StringRequeridoError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return StringRequeridoError.empty;

    return null;
  }
}
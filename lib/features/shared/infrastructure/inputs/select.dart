import 'package:formz/formz.dart';

// Define input validation errors
enum SelectError { empty }

// Extend FormzInput and provide the input type and error type.
class Select extends FormzInput<String, SelectError> {


  // Call super.pure to represent an unmodified form input.
  const Select.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Select.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == SelectError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  SelectError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return SelectError.empty;

    return null;
  }
}
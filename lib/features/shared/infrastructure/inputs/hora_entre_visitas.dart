import 'package:formz/formz.dart';

// Define input validation errors
enum HoraEntreVisitaError { empty }

// Extend FormzInput and provide the input type and error type.
class HoraEntreVisita extends FormzInput<String, HoraEntreVisitaError> {


  // Call super.pure to represent an unmodified form input.
  const HoraEntreVisita.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const HoraEntreVisita.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == HoraEntreVisitaError.empty ) return 'Es requerido, debe seleccionar una opción';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  HoraEntreVisitaError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return HoraEntreVisitaError.empty;

    return null;
  }
}
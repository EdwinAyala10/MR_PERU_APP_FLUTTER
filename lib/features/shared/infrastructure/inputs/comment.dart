import 'package:formz/formz.dart';

// Define input validation errors
enum CommentError { empty }

// Extend FormzInput and provide the input type and error type.
class Comment extends FormzInput<String, CommentError> {


  // Call super.pure to represent an unmodified form input.
  const Comment.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Comment.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == CommentError.empty ) return 'El campo comentario es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  CommentError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return CommentError.empty;

    return null;
  }
}
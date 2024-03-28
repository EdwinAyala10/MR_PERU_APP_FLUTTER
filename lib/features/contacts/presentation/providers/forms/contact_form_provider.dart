import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/shared.dart';

final contactFormProvider = StateNotifierProvider.autoDispose
    .family<ContactFormNotifier, ContactFormState, Contact>((ref, contact) {
  // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(contactsProvider.notifier).createOrUpdateContact;

  return ContactFormNotifier(
    contact: contact,
    onSubmitCallback: createUpdateCallback,
  );
});

class ContactFormNotifier extends StateNotifier<ContactFormState> {
  final Future<CreateUpdateContactResponse> Function(
      Map<dynamic, dynamic> contactLike)? onSubmitCallback;

  ContactFormNotifier({
    this.onSubmitCallback,
    required Contact contact,
  }) : super(ContactFormState(
          id: contact.id,
          ruc: Ruc.dirty(contact.ruc),
          contactIdIn: contact.contactIdIn ?? '',
          contactoCargo: contact.contactoCargo,
          contactoDesc: Name.dirty(contact.contactoDesc),
          contactoEmail: contact.contactoEmail ?? '',
          contactoFax: contact.contactoFax ?? '',
          contactoIdCargo: contact.contactoIdCargo ?? '',
          contactoNombreCargo: contact.contactoNombreCargo ?? '',
          contactoNotas: contact.contactoNotas ?? '',
          contactoTelefonoc: contact.contactoTelefonoc ?? '',
          contactoTelefonof: Phone.dirty(contact.contactoTelefonof),
          contactoTitulo: contact.contactoTitulo ?? '',
          opt: contact.opt ?? '',
          razon: contact.razon ?? '',
        ));

  Future<CreateUpdateContactResponse> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) {
      return CreateUpdateContactResponse(
          response: false, message: 'Campos requeridos.');
    }

    if (onSubmitCallback == null) {
      return CreateUpdateContactResponse(response: false, message: '');
    }

    final contactLike = {
      'CONTACTO_ID': (state.id == 'new') ? null : state.id,
      'RUC': state.ruc.value,
      'RAZON': state.razon ?? '',
      'CONTACTO_TITULO': state.contactoTitulo ?? '',
      'CONTACTO_DESC': state.contactoDesc.value,
      'CONTACTO_CARGO': state.contactoCargo,
      'CONTACTO_EMAIL': state.contactoEmail,
      'CONTACTO_TELEFONOF': state.contactoTelefonof.value,
      'CONTACTO_TELEFONOC': state.contactoTelefonoc,
      'CONTACTO_FAX': state.contactoFax,
      'CONTACTO_NOTAS': state.contactoNotas,
      'OPT': (state.id == 'new') ? 'INSERT' : 'UPDATE',
      'CONTACTO_ID_CARGO': state.contactoIdCargo,
      'CONTACTO_NOMBRE_CARGO': state.contactoNombreCargo,
    };

    try {
      return await onSubmitCallback!(contactLike);
    } catch (e) {
      return CreateUpdateContactResponse(response: false, message: '');
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Ruc.dirty(state.ruc.value),
        Name.dirty(state.contactoDesc.value),
        Phone.dirty(state.contactoTelefonof.value),
      ]),
    );
  }

  void onRucChanged(String value) {
    state = state.copyWith(
        ruc: Ruc.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(value),
          Name.dirty(state.contactoDesc.value),
          Phone.dirty(state.contactoTelefonof.value),
        ]));
  }

  void onRazonChanged(String razon) {
    state = state.copyWith(razon: razon);
  }

  void onNameChanged(String value) {
    state = state.copyWith(
        contactoDesc: Name.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Name.dirty(value),
          Phone.dirty(state.contactoTelefonof.value),
        ]));
  }

  void onCargoChanged(String idCargo) {
    state = state.copyWith(contactoIdCargo: idCargo);
  }

  void onNombreCargoChanged(String nameCargo) {
    state = state.copyWith(contactoNombreCargo: nameCargo, contactoCargo: nameCargo);
  }

  void onPhoneChanged(String value) {
    state = state.copyWith(
        contactoTelefonof: Phone.dirty(value),
        isFormValid: Formz.validate([
          Ruc.dirty(state.ruc.value),
          Name.dirty(state.contactoDesc.value),
          Phone.dirty(value),
        ]));
  }

  void onTelefonoNocChanged(String telefono) {
    state = state.copyWith(contactoTelefonoc: telefono);
  }

  void onEmailChanged(String email) {
    state = state.copyWith(contactoEmail: email);
  }

  void onComentarioChanged(String comentario) {
    state = state.copyWith(contactoNotas: comentario);
  }

}

class ContactFormState {
  final bool isFormValid;
  final String? id;
  final Ruc ruc;
  final String razon;

  final String contactoTitulo;
  final Name contactoDesc;
  final String contactoCargo;
  final String contactoEmail;
  final Phone contactoTelefonof;
  final String contactoTelefonoc;
  final String contactoFax;
  final String opt;
  final String contactIdIn;
  final String contactoIdCargo;
  final String contactoNombreCargo;
  final String contactoNotas;

  ContactFormState(
      {this.isFormValid = false,
      this.id,
      this.ruc = const Ruc.dirty(''),
      this.razon = '',
      this.contactoTitulo = '',
      this.contactoDesc = const Name.dirty(''),
      this.contactoCargo = '',
      this.contactoEmail = '',
      this.contactoTelefonof = const Phone.dirty(''),
      this.contactoTelefonoc = '',
      this.contactoFax = '',
      this.opt = '',
      this.contactIdIn = '',
      this.contactoIdCargo = '',
      this.contactoNombreCargo = '',
      this.contactoNotas = ''});

  ContactFormState copyWith({
    bool? isFormValid,
    Ruc? ruc,
    String? razon,
    String? id,
    String? contactoTitulo,
    Name? contactoDesc,
    String? contactoCargo,
    String? contactoEmail,
    Phone? contactoTelefonof,
    String? contactoTelefonoc,
    String? contactoFax,
    String? opt,
    String? contactIdIn,
    String? contactoIdCargo,
    String? contactoNombreCargo,
    String? contactoNotas,
  }) =>
      ContactFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        ruc: ruc ?? this.ruc,
        id: id ?? this.id,
        razon: razon ?? this.razon,
        contactoTitulo: contactoTitulo ?? this.contactoTitulo,
        contactoDesc: contactoDesc ?? this.contactoDesc,
        contactoCargo: contactoCargo ?? this.contactoCargo,
        contactoEmail: contactoEmail ?? this.contactoEmail,
        contactoTelefonof: contactoTelefonof ?? this.contactoTelefonof,
        contactoTelefonoc: contactoTelefonoc ?? this.contactoTelefonoc,
        contactoFax: contactoFax ?? this.contactoFax,
        opt: opt ?? this.opt,
        contactIdIn: contactIdIn ?? this.contactIdIn,
        contactoIdCargo: contactoIdCargo ?? this.contactoIdCargo,
        contactoNombreCargo: contactoNombreCargo ?? this.contactoNombreCargo,
        contactoNotas: contactoNotas ?? this.contactoNotas,
      );
}

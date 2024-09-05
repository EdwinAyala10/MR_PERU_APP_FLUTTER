import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../domain/domain.dart';
import '../providers.dart';
import '../../../../shared/shared.dart';

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
          ruc: StateCompany.dirty(contact.ruc),
          contactIdIn: contact.contactIdIn ?? '',
          contactoCargo: contact.contactoCargo,
          contactoDesc: Name.dirty(contact.contactoDesc),
          contactoEmail: contact.contactoEmail ?? '',
          contactoFax: contact.contactoFax ?? '',
          contactoLocalCodigo: StateLocal.dirty(contact.contactoLocalCodigo ?? ''),
          contactoLocalNombre: contact.contactoLocalNombre ?? '',
          contactoIdCargo: Cargo.dirty(contact.contactoIdCargo ?? ''),
          contactoNombreCargo: contact.contactoNombreCargo ?? '',
          contactoNotas: contact.contactoNotas ?? '',
          contactoTelefonoc: Phone.dirty(contact.contactoTelefonoc),
          contactoTelefonof: contact.contactoTelefonof ?? '',
          contactoTitulo: contact.contactoTitulo,
          opt: contact.opt ?? '',
          razon: contact.razon ?? '',
          contactoUsuarioRegistro: contact.contactoUsuarioRegistro ?? '',
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
      'RAZON': state.razon,
      'CONTACTO_TITULO': state.contactoTitulo,
      'CONTACTO_DESC': state.contactoDesc.value,
      'CONTACTO_CARGO': state.contactoCargo,
      'CONTACTO_EMAIL': state.contactoEmail,
      'CONTACTO_TELEFONOF': state.contactoTelefonof,
      'CONTACTO_TELEFONOC': state.contactoTelefonoc.value,
      'CONTACTO_FAX': state.contactoFax,
      'CONTACTO_NOTAS': state.contactoNotas,
      'CONTACTO_LOCAL_CODIGO': state.contactoLocalCodigo.value,
      //'OPT': (state.id == 'new') ? 'INSERT' : 'UPDATE',
      'CONTACTO_ID_CARGO': state.contactoIdCargo.value,
      'CONTACTO_NOMBRE_CARGO': state.contactoNombreCargo,
      'CONTACTO_USUARIO_REGISTRO': state.contactoUsuarioRegistro,
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
        StateCompany.dirty(state.ruc.value),
        Name.dirty(state.contactoDesc.value),
        Phone.dirty(state.contactoTelefonoc.value),
        Cargo.dirty(state.contactoIdCargo.value),
        StateLocal.dirty(state.contactoLocalCodigo.value),
      ]),
    );
  }

  void onRucChanged(String value) {
    state = state.copyWith(
        ruc: StateCompany.dirty(value),
        contactoLocalCodigo: const StateLocal.dirty(''),
        isFormValid: Formz.validate([
          StateCompany.dirty(value),
          Name.dirty(state.contactoDesc.value),
          Phone.dirty(state.contactoTelefonoc.value),
          Cargo.dirty(state.contactoIdCargo.value),
          StateLocal.dirty(state.contactoLocalCodigo.value),
        ]));
  }

  void onRazonChanged(String razon) {
    state = state.copyWith(razon: razon);
  }

  void onNameChanged(String value) {
    state = state.copyWith(
        contactoDesc: Name.dirty(value),
        isFormValid: Formz.validate([
          StateCompany.dirty(state.ruc.value),
          Name.dirty(value),
          Phone.dirty(state.contactoTelefonoc.value),
          Cargo.dirty(state.contactoIdCargo.value),
          StateLocal.dirty(state.contactoLocalCodigo.value),
        ]));
  }

  void onCargoChanged(String idCargo) {
    //state = state.copyWith(contactoIdCargo: idCargo);
    state = state.copyWith(
        contactoIdCargo: Cargo.dirty(idCargo),
        isFormValid: Formz.validate([
          StateCompany.dirty(state.ruc.value),
          Name.dirty(state.contactoDesc.value),
          Phone.dirty(state.contactoTelefonoc.value),
          Cargo.dirty(idCargo),
          StateLocal.dirty(state.contactoLocalCodigo.value),
        ]));
  }

  void onLocalChanged(String value, String name) {
    state = state.copyWith(
        contactoLocalCodigo: StateLocal.dirty(value),
        contactoLocalNombre: name,
        isFormValid: Formz.validate([
          StateCompany.dirty(state.ruc.value),
          Name.dirty(state.contactoDesc.value),
          Phone.dirty(state.contactoTelefonoc.value),
          Cargo.dirty(state.contactoIdCargo.value),
          StateLocal.dirty(value),
        ]));
  }

  void onNombreCargoChanged(String nameCargo) {
    state = state.copyWith(
        contactoNombreCargo: nameCargo, contactoCargo: nameCargo);
  }

  void onPhoneChanged(String value) {
    state = state.copyWith(contactoTelefonof: value);
  }

  void onTelefonoNocChanged(String telefono) {
    state = state.copyWith(
        contactoTelefonoc: Phone.dirty(telefono),
        isFormValid: Formz.validate([
          StateCompany.dirty(state.ruc.value),
          Name.dirty(state.contactoDesc.value),
          Phone.dirty(telefono),
          Cargo.dirty(state.contactoIdCargo.value),
          StateLocal.dirty(state.contactoLocalCodigo.value),
        ]));
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
  final bool isLoading;
  final String? id;
  final StateCompany ruc;
  final String razon;

  final String contactoTitulo;
  final Name contactoDesc;
  final String contactoCargo;
  final String contactoEmail;
  final Phone contactoTelefonoc;
  final String contactoTelefonof;
  final String contactoFax;
  final String opt;
  final String contactIdIn;
  final Cargo contactoIdCargo;
  final String contactoNombreCargo;
  final String contactoNotas;
  final String? contactoUsuarioRegistro;
  final StateLocal contactoLocalCodigo;
  final String? contactoLocalNombre;

  ContactFormState(
      {this.isFormValid = false,
      this.isLoading = false,
      this.id,
      this.ruc = const StateCompany.dirty(''),
      this.razon = '',
      this.contactoTitulo = '',
      this.contactoDesc = const Name.dirty(''),
      this.contactoCargo = '',
      this.contactoEmail = '',
      this.contactoTelefonoc = const Phone.dirty(''),
      this.contactoTelefonof = '',
      this.contactoFax = '',
      this.opt = '',
      this.contactIdIn = '',
      this.contactoIdCargo = const Cargo.dirty(''),
      this.contactoNombreCargo = '',
      this.contactoUsuarioRegistro = '',
      this.contactoLocalCodigo = const StateLocal.dirty(''),
      this.contactoLocalNombre = '',
      this.contactoNotas = ''});

  ContactFormState copyWith({
    bool? isFormValid,
    bool? isLoading,
    StateCompany? ruc,
    String? razon,
    String? id,
    String? contactoTitulo,
    Name? contactoDesc,
    String? contactoCargo,
    String? contactoEmail,
    Phone? contactoTelefonoc,
    String? contactoTelefonof,
    String? contactoFax,
    String? opt,
    String? contactIdIn,
    Cargo? contactoIdCargo,
    String? contactoNombreCargo,
    String? contactoNotas,
    StateLocal? contactoLocalCodigo,
    String? contactoLocalNombre,
    String? contactoUsuarioRegistro,
  }) =>
      ContactFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        isLoading: isLoading ?? this.isLoading,
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
        contactoUsuarioRegistro: contactoUsuarioRegistro ?? this.contactoUsuarioRegistro,
        opt: opt ?? this.opt,
        contactIdIn: contactIdIn ?? this.contactIdIn,
        contactoIdCargo: contactoIdCargo ?? this.contactoIdCargo,
        contactoNombreCargo: contactoNombreCargo ?? this.contactoNombreCargo,
        contactoNotas: contactoNotas ?? this.contactoNotas,
        contactoLocalCodigo: contactoLocalCodigo ?? this.contactoLocalCodigo,
        contactoLocalNombre: contactoLocalNombre ?? this.contactoLocalNombre,
      );
}

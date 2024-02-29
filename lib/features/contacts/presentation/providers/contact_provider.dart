import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';

import 'contacts_repository_provider.dart';

final contactProvider = StateNotifierProvider.autoDispose
    .family<ContactNotifier, ContactState, String>((ref, id) {
  final contactsRepository = ref.watch(contactsRepositoryProvider);

  return ContactNotifier(contactsRepository: contactsRepository, id: id);
});

class ContactNotifier extends StateNotifier<ContactState> {
  final ContactsRepository contactsRepository;

  ContactNotifier({
    required this.contactsRepository,
    required String id,
  }) : super(ContactState(id: id)) {
    loadContact();
  }

  Contact newEmptyContact() {
    return Contact(
      id: 'new',
      contactoCargo: '',
      contactoDesc: '',
      contactoTelefonof: '',
      contactoTitulo: 'SR',
      contactIdIn: '',
      contactoEmail: '',
      contactoFax: '',
      contactoIdCargo: '',
      contactoNombreCargo: '',
      contactoNotas: '',
      contactoTelefonoc: '',
      opt: '',
      ruc: '',
    );
  }

  Future<void> loadContact() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          contact: newEmptyContact(),
        );

        state.contact?.opt = 'INSERT';
        return;
      } else {
        state.contact?.opt = 'UPDATE';
        state.contact?.contactIdIn = state.id;
      }

      final contact = await contactsRepository.getContactById(state.id);

      state = state.copyWith(isLoading: false, contact: contact);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class ContactState {
  final String id;
  final Contact? contact;
  final bool isLoading;
  final bool isSaving;

  ContactState({
    required this.id,
    this.contact,
    this.isLoading = true,
    this.isSaving = false,
  });

  ContactState copyWith({
    String? id,
    Contact? contact,
    bool? isLoading,
    bool? isSaving,
  }) =>
      ContactState(
        id: id ?? this.id,
        contact: contact ?? this.contact,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

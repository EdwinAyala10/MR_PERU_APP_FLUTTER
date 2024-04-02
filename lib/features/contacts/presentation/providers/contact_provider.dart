import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';

import 'contacts_repository_provider.dart';

final contactProvider = StateNotifierProvider.autoDispose
    .family<ContactNotifier, ContactState, String>((ref, id) {
  final contactsRepository = ref.watch(contactsRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return ContactNotifier(
      contactsRepository: contactsRepository, user: user!, id: id);
});

class ContactNotifier extends StateNotifier<ContactState> {
  final ContactsRepository contactsRepository;
  User user;

  ContactNotifier({
    required this.contactsRepository,
    required this.user,
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
      razon: '',
      opt: '',
      ruc: '',
      contactoUsuarioRegistro: user.code,
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
      state = state.copyWith(isLoading: false, contact: null);
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

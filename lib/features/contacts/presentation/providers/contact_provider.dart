import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

import 'contacts_repository_provider.dart';

final contactProvider = StateNotifierProvider.autoDispose
    .family<ContactNotifier, ContactState, String>((ref, id) {
  final contactsRepository = ref.watch(contactsRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return ContactNotifier(
      contactsRepository: contactsRepository, user: user!, idContact: id);
});

class ContactNotifier extends StateNotifier<ContactState> {
  final ContactsRepository contactsRepository;
  User user;

  ContactNotifier({
    required this.contactsRepository,
    required this.user,
    required String idContact,
  }) : super(ContactState()) {
    loadContact(idContact);
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
      contactoLocalCodigo: '',
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

  Future<void> isSaving() async {
    state = state.copyWith(isSaving: true);
  }

  Future<void> isNotSaving() async {
    state = state.copyWith(isSaving: false);
  }

  Future<void> loadContact(String idContact) async {
    try {
      if (idContact == 'new') {
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

      final contact = await contactsRepository.getContactById(idContact);

      state = state.copyWith(isLoading: false, contact: contact, id: idContact);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, contact: null);
      }
      // 404 product not found
    }
  }
}

class ContactState {
  final String? id;
  final Contact? contact;
  final bool isLoading;
  final bool isSaving;

  ContactState({
    this.id,
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

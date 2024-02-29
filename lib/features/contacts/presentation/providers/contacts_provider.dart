import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';

import 'contacts_repository_provider.dart';

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  final contactsRepository = ref.watch(contactsRepositoryProvider);
  return ContactsNotifier(contactsRepository: contactsRepository);
});

class ContactsNotifier extends StateNotifier<ContactsState> {
  final ContactsRepository contactsRepository;

  ContactsNotifier({required this.contactsRepository})
      : super(ContactsState()) {
    loadNextPage();
  }

  Future<CreateUpdateContactResponse> createOrUpdateContact(
      Map<dynamic, dynamic> contactLike) async {
    try {
      final contactResponse =
          await contactsRepository.createUpdateContact(contactLike);

      final message = contactResponse.message;

      if (contactResponse.status) {

        final contact = contactResponse.contact as Contact;
        final isContactInList =
            state.contacts.any((element) => element.id == contact.id);

        if (!isContactInList) {
          state = state.copyWith(contacts: [...state.contacts, contact]);
          return CreateUpdateContactResponse(response: true, message: message);
        }

        state = state.copyWith(
            contacts: state.contacts
                .map(
                  (element) => (element.id == contact.id) ? contact : element,
                )
                .toList());

        return CreateUpdateContactResponse(response: true, message: message);
      }

      return CreateUpdateContactResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateContactResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final contacts = await contactsRepository.getContacts();

    if (contacts.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        contacts: [...state.contacts, ...contacts]);
  }
}

class ContactsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Contact> contacts;

  ContactsState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.contacts = const []});

  ContactsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Contact>? contacts,
  }) =>
      ContactsState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        contacts: contacts ?? this.contacts,
      );
}
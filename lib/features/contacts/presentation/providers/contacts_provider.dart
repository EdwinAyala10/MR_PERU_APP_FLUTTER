import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

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
    loadNextPage(isRefresh: true);
  }

  Future<CreateUpdateContactResponse> createOrUpdateContact(
      Map<dynamic, dynamic> contactLike) async {
    try {
      final contactResponse =
          await contactsRepository.createUpdateContact(contactLike);

      final message = contactResponse.message;

      if (contactResponse.status) {

        final contact = contactResponse.contact as Contact;
        print('CONTACT X');
        print(contact.id);
        /*final contact = contactResponse.contact as Contact;
        final isContactInList =
            state.contacts.any((element) => element.id == contact.id);

        if (!isContactInList) {
          state = state.copyWith(contacts: [contact, ...state.contacts]);
          return CreateUpdateContactResponse(response: true, message: message);
        }

        state = state.copyWith(
            contacts: state.contacts
                .map(
                  (element) => (element.id == contact.id) ? contact : element,
                )
                .toList());*/

        return CreateUpdateContactResponse(response: true, message: message, id: contact.ruc);
      }

      return CreateUpdateContactResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateContactResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

  void onChangeIsActiveSearch() {
    state = state.copyWith(
      isActiveSearch: true,
    );
  }

  void onChangeTextSearch(String text) {
    state = state.copyWith(textSearch: text);
    loadNextPage(isRefresh: true);
  }

  void onChangeNotIsActiveSearch() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
      loadNextPage(isRefresh: true);
    //}
  }

  void onChangeNotIsActiveSearchSinRefresh() {
    state = state.copyWith(isActiveSearch: false, textSearch: '');
    //if (state.textSearch != "") {
      //loadNextPage(isRefresh: true);
    //}
  }

  Future loadNextPage({bool isRefresh = false}) async {
    final search = state.textSearch;

    if (isRefresh) {
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);
    } else {
      if (state.isReload || state.isLastPage) return;  
      state = state.copyWith(isReload: true);
    }

    int sLimit = state.limit;
    int sOffset = state.offset;

    if (isRefresh) {
      sLimit = 10;
      sOffset = 0;
    } else {
      sOffset = state.offset + 10;
    }

    print('sLimit CONTACTO x: ${sLimit}');
    print('sOffset CONTACTO x: ${sOffset}');

    final contacts = await contactsRepository.getContacts(
      search: search,
      limit: sLimit,
      offset: sOffset,
      ruc: ''
    );

    print('total contacts: ${contacts.length}');

    if (contacts.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true);
      if (isRefresh) {
        state = state.copyWith(isLoading: false, isLastPage: true);    
      } else {
        state = state.copyWith(isReload: false, isLastPage: true);
      }
      return;
    }

    int newOffset;
    List<Contact> newContacts;

    if (isRefresh) {
      newOffset = 0;
      newContacts = contacts;
    } else {
      newOffset = sOffset;
      newContacts = [...state.contacts, ...contacts];
    }

      print('Offset CONTACTO: ${newOffset}');


    if (isRefresh) {
      state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        contacts: newContacts,
        offset: newOffset
      );
    } else {
      state = state.copyWith(
        isLastPage: false,
        isReload: false,
        contacts: newContacts,
        offset: newOffset
      );
    }

    /*state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        contacts: [...state.contacts, ...contacts]);*/
  }

  Future loadContactFilter(String ruc) async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final contacts = await contactsRepository.getContacts(ruc: ruc, search: '');

    if (contacts.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        //contacts: [...state.contacts, ...contacts]
        contacts: contacts
    );
  }
}

class ContactsState {
  final bool isLastPage;
  final bool isReload;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Contact> contacts;
  final bool isActiveSearch;
  final String textSearch;

  ContactsState(
      {this.isLastPage = false,
      this.isReload = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.isActiveSearch = false,
      this.textSearch = '',
      this.contacts = const []});

  ContactsState copyWith({
    bool? isLastPage,
    bool? isReload,
    int? limit,
    int? offset,
    bool? isLoading,
    bool? isActiveSearch,
    String? textSearch,
    List<Contact>? contacts,
  }) =>
      ContactsState(
        isLastPage: isLastPage ?? this.isLastPage,
        isReload: isReload ?? this.isReload,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        contacts: contacts ?? this.contacts,
        isActiveSearch: isActiveSearch ?? this.isActiveSearch,
        textSearch: textSearch ?? this.textSearch,
      );
}

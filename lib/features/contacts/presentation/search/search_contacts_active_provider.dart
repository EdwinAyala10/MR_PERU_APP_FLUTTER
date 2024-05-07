import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryContactsProvider = StateProvider<String>((ref) => '');

final searchedContactsProvider = StateNotifierProvider<SearchedContactsNotifier, List<Contact>>((ref) {

  final contactRepository = ref.read( contactsRepositoryProvider );

  return SearchedContactsNotifier(
    searchContacts: contactRepository.searchContacts, 
    ref: ref
  );
});


typedef SearchContactsCallback = Future<List<Contact>> Function(String query, String ruc);

class SearchedContactsNotifier extends StateNotifier<List<Contact>> {

  final SearchContactsCallback searchContacts;
  final Ref ref;

  SearchedContactsNotifier({
    required this.searchContacts,
    required this.ref,
  }): super([]);


  Future<List<Contact>> searchContactsByQuery( String query, String ruc ) async{
    final List<Contact> contacts = await searchContacts(query, ruc);
    ref.read(searchQueryContactsProvider.notifier).update((state) => query);

    state = contacts;
    return contacts;
  }

}







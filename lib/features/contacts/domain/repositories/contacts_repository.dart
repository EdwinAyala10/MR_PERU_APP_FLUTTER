import '../domain.dart';

abstract class ContactsRepository {
  Future<List<Contact>> getContacts({String ruc, String search, int limit = 10, int offset = 0});
  Future<Contact> getContactById(String rucId);

  Future<ContactResponse> createUpdateContact(
      Map<dynamic, dynamic> contactLike);
  Future<List<Contact>> searchContacts(String query, String ruc);
}

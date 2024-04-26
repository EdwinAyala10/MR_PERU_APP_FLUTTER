import 'package:crm_app/features/contacts/domain/domain.dart';

class ContactsRepositoryImpl extends ContactsRepository {

  final ContactsDatasource datasource;

  ContactsRepositoryImpl(this.datasource);

  @override
  Future<ContactResponse> createUpdateContact(Map<dynamic, dynamic> contactLike) {
    return datasource.createUpdateContact(contactLike);
  }

  @override
  Future<Contact> getContactById(String rucId) {
    return datasource.getContactById(rucId);
  }

  @override
  Future<List<Contact>> getContacts(String ruc, String search) {
    return datasource.getContacts(ruc, search);
  }

  @override
  Future<List<Contact>> searchContacts(String query, String ruc) {
    return datasource.searchContacts(query, ruc);
  }

}
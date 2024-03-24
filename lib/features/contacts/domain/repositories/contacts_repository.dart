
import 'package:crm_app/features/contacts/domain/domain.dart';

abstract class ContactsRepository {

  Future<List<Contact>> getContacts(String ruc);
  Future<Contact> getContactById(String rucId);

  Future<ContactResponse> createUpdateContact( Map<dynamic,dynamic> contactLike );
  Future<List<Contact>> searchContacts(String query);
}


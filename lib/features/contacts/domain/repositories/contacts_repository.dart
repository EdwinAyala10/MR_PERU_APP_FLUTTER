
import 'package:crm_app/features/contacts/domain/domain.dart';

abstract class ContactsRepository {

  Future<List<Contact>> getContacts();
  Future<Contact> getContactById(String rucId);

  Future<ContactResponse> createUpdateContact( Map<dynamic,dynamic> contactLike );

}


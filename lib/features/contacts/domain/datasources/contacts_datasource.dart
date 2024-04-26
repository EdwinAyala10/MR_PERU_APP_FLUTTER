import 'package:crm_app/features/contacts/domain/domain.dart';

abstract class ContactsDatasource {

  Future<List<Contact>> getContacts(String ruc, String search);
  Future<Contact> getContactById(String id);

  Future<ContactResponse> createUpdateContact( Map<dynamic,dynamic> contactLike );

  Future<List<Contact>> searchContacts(String query, String ruc);

}


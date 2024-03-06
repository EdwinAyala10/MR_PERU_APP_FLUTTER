import 'package:crm_app/features/contacts/infrastructure/mappers/contact_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';

import '../errors/contact_errors.dart';
import '../mappers/contact_mapper.dart';

class ContactsDatasourceImpl extends ContactsDatasource {
  late final Dio dio;
  final String accessToken;

  ContactsDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<ContactResponse> createUpdateContact(
      Map<dynamic, dynamic> contactLike) async {

        print('CONTACT: ${contactLike}');
    try {
      final String? id = contactLike['CONTACTO_ID'];
      final String method = 'POST';
      final String url = '/contacto/create-contacto-cliente';

      //companyLike.remove('rucId');

      final response = await dio.request(url,
          data: contactLike, options: Options(method: method));

      print('RESPONSE: ${response}');

      final ContactResponse contactResponse =
          ContactResponseMapper.jsonToEntity(response.data);

      if (contactResponse.status == true) {
        contactResponse.contact =
            ContactMapper.jsonToEntity(response.data['data']);
      }

      return contactResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ContactNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Contact> getContactById(String id) async {
    try {
      final response = await dio.get('/contacto/listar-contacto-by-id/$id');
      final Contact contact = ContactMapper.jsonToEntity(response.data['data']);

      return contact;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ContactNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Contact>> getContacts() async {
    final response =
        await dio.post('/contacto/listar-contacto-by-ruc-cargo-responsable');
    final List<Contact> contacts = [];
    for (final contact in response.data['data'] ?? []) {
      contacts.add(ContactMapper.jsonToEntity(contact));
    }

    return contacts;
  }

  
  @override
  Future<List<Contact>> searchContacts(String query) async {

    final data = {
      "SEARCH": query,
    };

    final response =
        await dio.post('/contacto/listar-contacto-by-nombre', data: data);
    final List<Contact> contacts = [];
    for (final contact in response.data['data'] ?? []) {
      contacts.add(ContactMapper.jsonToEntity(contact));
    }

    return contacts;
  }
}

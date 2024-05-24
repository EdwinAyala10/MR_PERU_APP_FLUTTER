import '../domain.dart';

abstract class ResourceDetailsRepository {

  Future<List<ResourceDetail>> getResourceDetailsByGroup(String idGroup);

}


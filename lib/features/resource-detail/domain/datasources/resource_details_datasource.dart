

import '../domain.dart';

abstract class ResourceDetailsDatasource {

  Future<List<ResourceDetail>> getResourceDetailsByGroup(String idGroup);

}


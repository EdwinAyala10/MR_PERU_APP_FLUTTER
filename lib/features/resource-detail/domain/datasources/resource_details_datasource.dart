

import 'package:crm_app/features/resource-detail/domain/domain.dart';

abstract class ResourceDetailsDatasource {

  Future<List<ResourceDetail>> getResourceDetailsByGroup(String idGroup);

}


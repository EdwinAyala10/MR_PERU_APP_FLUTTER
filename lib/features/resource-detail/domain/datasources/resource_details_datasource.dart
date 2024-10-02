

import '../domain.dart';

abstract class ResourceDetailsDatasource {

  Future<List<ResourceDetail>> getResourceDetailsByGroup({ String idGroup = '', String idCodigo = '' });
  Future<List<ResourceDetail>> getResourceDetailsVisibleByGroup({ String idGroup = '', String idCodigo = '' });

}


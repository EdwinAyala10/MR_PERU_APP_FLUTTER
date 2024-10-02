import '../../domain/domain.dart';

class ResourceDetailsRepositoryImpl extends ResourceDetailsRepository {

  final ResourceDetailsDatasource datasource;

  ResourceDetailsRepositoryImpl(this.datasource);

  @override
  Future<List<ResourceDetail>> getResourceDetailsByGroup({ String idGroup = '', String idCodigo = '' }) {
    return datasource.getResourceDetailsByGroup(idGroup: idGroup, idCodigo: idCodigo);
  }
  
  @override
  Future<List<ResourceDetail>> getResourceDetailsVisibleByGroup({ String idGroup = '', String idCodigo = '' }) {
    return datasource.getResourceDetailsVisibleByGroup(idGroup: idGroup, idCodigo: idCodigo);
  }

}
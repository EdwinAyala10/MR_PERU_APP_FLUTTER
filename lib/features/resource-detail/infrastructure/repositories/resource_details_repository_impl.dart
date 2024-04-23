import 'package:crm_app/features/resource-detail/domain/domain.dart';

class ResourceDetailsRepositoryImpl extends ResourceDetailsRepository {

  final ResourceDetailsDatasource datasource;

  ResourceDetailsRepositoryImpl(this.datasource);

  @override
  Future<List<ResourceDetail>> getResourceDetailsByGroup(String idGroup) {
    return datasource.getResourceDetailsByGroup(idGroup);
  }

}
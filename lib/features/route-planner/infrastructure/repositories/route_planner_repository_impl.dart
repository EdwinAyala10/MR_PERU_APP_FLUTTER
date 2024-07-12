
import '../../domain/domain.dart';

class RoutePlannerRepositoryImpl extends RoutePlannerRepository {
  final RoutePlannerDatasource datasource;

  RoutePlannerRepositoryImpl(this.datasource);


  @override
  Future<List<CompanyLocalRoutePlanner>> getCompanyLocals({ 
    int limit = 10, 
    int offset = 0, 
    String search = '',
    List<FilterOption> filters = const [] 
  }) {
    return datasource.getCompanyLocals(limit: limit, offset: offset, search: search, filters: filters);
  }
  
  @override
  Future<List<FilterActivity>> getFilterActivities() {
    return datasource.getFilterActivities();
  }
  
  @override
  Future<List<FilterCodigoPostal>> getFilterCodigoPostal({String search = ''}) {
    return datasource.getFilterCodigoPostal(search: search);
  }
  
  @override
  Future<List<FilterDistrito>> getFilterDistrito({String search = ''}) {
    return datasource.getFilterDistrito(search: search);

  }
  
  @override
  Future<List<FilterResponsable>> getFilterResponsable({String search = ''}) {
    return datasource.getFilterResponsable(search: search);
  }
  
  @override
  Future<List<FilterRucRazonSocial>> getFilterRucRazonSocial({String search = ''}) {
    return datasource.getFilterRucRazonSocial(search: search);
  }

}

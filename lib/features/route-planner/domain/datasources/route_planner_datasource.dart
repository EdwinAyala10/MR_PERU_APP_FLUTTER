

import '../domain.dart';

abstract class RoutePlannerDatasource {

  Future<List<CompanyLocalRoutePlanner>> getCompanyLocals({ 
    int limit = 10, 
    int offset = 0, 
    String search,
    List<FilterOption> filters = const []
  });
  Future<List<FilterActivity>> getFilterActivities();

  Future<List<FilterResponsable>> getFilterResponsable({ String search });
  Future<List<FilterCodigoPostal>> getFilterCodigoPostal({ String search });
  Future<List<FilterDistrito>> getFilterDistrito({ String search });
  Future<List<FilterRucRazonSocial>> getFilterRucRazonSocial({ String search });
  
}


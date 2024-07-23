
import 'package:crm_app/features/route-planner/domain/entities/event_planner_response.dart';

import '../domain.dart';

abstract class RoutePlannerRepository {

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

  Future<EventPlannerResponse> createEventPlanner( Map<dynamic,dynamic> eventLike );
}


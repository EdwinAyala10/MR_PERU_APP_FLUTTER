import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/opportunities/domain/entities/status_opportunity.dart';

abstract class ActivitiesDatasource {

  Future<List<Activity>> getActivities(String search);
  Future<List<Activity>> getActivitiesByRuc(String ruc);
  Future<Activity> getActivityById(String id);

  Future<ActivityResponse> createUpdateActivity( Map<dynamic,dynamic> activityLike );

}


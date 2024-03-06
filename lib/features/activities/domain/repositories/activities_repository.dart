import 'package:crm_app/features/activities/domain/domain.dart';


abstract class ActivitiesRepository {

  Future<List<Activity>> getActivities();
  Future<Activity> getActivityById(String id);

  Future<ActivityResponse> createUpdateActivity( Map<dynamic,dynamic> activityLike );

}


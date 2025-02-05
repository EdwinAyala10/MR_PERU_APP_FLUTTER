import '../domain.dart';

abstract class ActivitiesRepository {
  Future<List<Activity>> getActivities({
    String search,
    int limit = 10,
    int offset = 0,
    String idUsuario = ''
  });

  Future<List<Activity>> getActivitiesByOpportunitie({
    String opportunityId,
    String search,
    int limit = 10,
    int offset = 0,
  });

  Future<List<Activity>> getActivitiesByRuc(String ruc);

  Future<Activity> getActivityById(String id);

  Future<ActivityResponse> createUpdateActivity(
      Map<dynamic, dynamic> activityLike);
}

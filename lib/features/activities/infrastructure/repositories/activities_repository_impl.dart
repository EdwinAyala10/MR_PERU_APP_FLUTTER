import 'package:crm_app/features/activities/domain/domain.dart';

class ActivitiesRepositoryImpl extends ActivitiesRepository {

  final ActivitiesDatasource datasource;

  ActivitiesRepositoryImpl(this.datasource);

  @override
  Future<ActivityResponse> createUpdateActivity(Map<dynamic, dynamic> activityLike) {
    return datasource.createUpdateActivity(activityLike);
  }

  @override
  Future<Activity> getActivityById(String id) {
    return datasource.getActivityById(id);
  }

  @override
  Future<List<Activity>> getActivities(String search) {
    return datasource.getActivities(search);
  }

  @override
  Future<List<Activity>> getActivitiesByRuc(String ruc) {
    return datasource.getActivitiesByRuc(ruc);
  }

}
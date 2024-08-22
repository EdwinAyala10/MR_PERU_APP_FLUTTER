import '../../domain/domain.dart';

class ActivitiesRepositoryImpl extends ActivitiesRepository {
  final ActivitiesDatasource datasource;

  ActivitiesRepositoryImpl(this.datasource);

  @override
  Future<ActivityResponse> createUpdateActivity(
      Map<dynamic, dynamic> activityLike) {
    return datasource.createUpdateActivity(activityLike);
  }

  @override
  Future<Activity> getActivityById(String id) {
    return datasource.getActivityById(id);
  }

  @override
  Future<List<Activity>> getActivities(
      {String search = '', int limit = 10, int offset = 0}) {
    return datasource.getActivities(
        search: search, limit: limit, offset: offset);
  }

  @override
  Future<List<Activity>> getActivitiesByRuc(String ruc) {
    return datasource.getActivitiesByRuc(ruc);
  }

  @override
  Future<List<Activity>> getActivitiesByOpportunitie({
    String opportunityId = '',
    String search = '',
    int limit = 10,
    int offset = 0,
  }) {
    return datasource.getActivitiesByOpportunitie(
      opportunityId: opportunityId,
      search: search,
      limit: limit,
      offset: offset,
    );
  }
}

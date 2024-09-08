import '../mappers/activity_response_mapper.dart';
import 'package:dio/dio.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

import '../errors/activity_errors.dart';
import '../mappers/activity_mapper.dart';

class ActivitiesDatasourceImpl extends ActivitiesDatasource {
  late final Dio dio;
  final String accessToken;

  ActivitiesDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));
  @override
  Future<ActivityResponse> createUpdateActivity(
      Map<dynamic, dynamic> activityLike) async {
    try {
      final String? id = activityLike['ACTI_ID_ACTIVIDAD'];
      const String method = 'POST';
      final String url = id == null
          ? '/actividad/create-actividad'
          : '/actividad/edit-actividad';

      if (id == null) {
        activityLike.remove('ACTI_ID_ACTIVIDAD');
      }

      final response = await dio.request(url,
          data: activityLike, options: Options(method: method));

      final ActivityResponse activityResponse =
          ActivityResponseMapper.jsonToEntity(response.data);

      if (activityResponse.status == true) {
        activityResponse.activity =
            ActivityMapper.jsonToEntity(response.data['data']);
      }

      return activityResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ActivityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Activity> getActivityById(String id) async {
    try {
      final response = await dio.get('/actividad/listar-actividad-by-id/$id');
      final Activity activity =
          ActivityMapper.jsonToEntity(response.data['data']);

      return activity;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ActivityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Activity>> getActivities(
      {String search = '', int limit = 10, int offset = 0}) async {
    try {
      final response = await dio.post(
          '/actividad/listar-actividad-by-id-tipo-gestion',
          data: {'SEARCH': search, 'OFFSET': offset, 'TOP': limit});
      final List<Activity> activities = [];
      for (final activity in response.data['data'] ?? []) {
        activities.add(ActivityMapper.jsonToEntity(activity));
      }

      return activities;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Activity>> getActivitiesByRuc(String ruc) async {
    final data = {
      "RUC": ruc,
    };

    final response =
        await dio.post('/actividad/listar-actividad-by-ruc', data: data);
    final List<Activity> activities = [];
    for (final activity in response.data['data'] ?? []) {
      activities.add(ActivityMapper.jsonToEntity(activity));
    }

    return activities;
  }

  @override
  Future<List<Activity>> getActivitiesByOpportunitie({
    String opportunityId = '',
    String search = '',
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response =
          await dio.post('/actividad/listar-actividad-by-oportunidad', data: {
        'SEARCH': '',
        'OFFSET': offset,
        'TOP': limit,
        'ACTI_ID_OPORTUNIDAD': opportunityId
      });
      final List<Activity> activities = [];
      for (final activity in response.data['data'] ?? []) {
        activities.add(ActivityMapper.jsonToEntity(activity));
      }

      return activities;
    } catch (e) {
      throw Exception();
    }
  }
}

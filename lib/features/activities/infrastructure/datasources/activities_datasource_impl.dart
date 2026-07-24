import 'dart:convert';

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

      // Se envía como form-data con notación de corchetes (igual que el
      // envío de correo en email_datasource_impl.dart), ya que el backend
      // solo arma los arrays (ACTI_OPORTUNIDAD, ACTIVIDADES_CONTACTO, etc.)
      // a partir de un body de formulario, no de un array JSON anidado.
      final formData = _toFormData(activityLike);

      print('ACTIVIDAD -> endpoint: $url');
      for (final field in formData.fields) {
        if (field.key.startsWith('ACTI_OPORTUNIDAD') ||
            field.key == 'ACTI_ID_OPORTUNIDAD') {
          print('ACTIVIDAD -> ${field.key} = ${field.value}');
        }
      }

      final response = await dio.request(url,
          data: formData, options: Options(method: method));

      final ActivityResponse activityResponse =
          ActivityResponseMapper.jsonToEntity(response.data);

      final responseData = response.data;
      if (activityResponse.status == true &&
          responseData is Map &&
          responseData['data'] is Map) {
        activityResponse.activity =
            ActivityMapper.jsonToEntity(responseData['data']);
      }

      return activityResponse;
    } on DioException catch (e) {
      print(
          'ACTIVIDAD -> error dio: status ${e.response?.statusCode}, data ${e.response?.data}, message ${e.message}');
      if (e.response?.statusCode == 404) throw ActivityNotFound();
      rethrow;
    } catch (e) {
      print('ACTIVIDAD -> error inesperado: $e');
      rethrow;
    }
  }

  /// Aplana un mapa tipo `{'ACTI_OPORTUNIDAD': [{'ACTI_ID_OPORTUNIDAD': '1', ...}, ...]}`
  /// a campos de formulario `ACTI_OPORTUNIDAD[0][ACTI_ID_OPORTUNIDAD]`, etc,
  /// igual que `SendEmailRequest.toFormData()`.
  FormData _toFormData(Map<dynamic, dynamic> data) {
    final formData = FormData();
    data.forEach((key, value) {
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is Map) {
            item.forEach((subKey, subValue) {
              formData.fields.add(
                MapEntry('$key[$i][$subKey]', subValue?.toString() ?? ''),
              );
            });
          } else {
            formData.fields.add(MapEntry('$key[$i]', item?.toString() ?? ''));
          }
        }
      } else {
        formData.fields.add(MapEntry(key.toString(), value?.toString() ?? ''));
      }
    });
    return formData;
  }

  @override
  Future<Activity> getActivityById(String id) async {
    try {
      final response = await dio.get('/actividad/listar-actividad-by-id/$id');

      // DEBUG: Verificar qué actividad devuelve el backend
      print('========== BACKEND RESPONSE DEBUG ==========');
      print('Requested Activity ID: $id');
      print(
          'Returned Activity ID: ${response.data['data']['ACTI_ID_ACTIVIDAD']}');

      final emlsJson = response.data['data']['EMLS_JSON_EMAIL_MICROSOFT'];
      if (emlsJson != null) {
        print('Has EMLS_JSON_EMAIL_MICROSOFT: YES');
        final attachments = emlsJson is String
            ? jsonDecode(emlsJson)['attachments']
            : emlsJson['attachments'];
        if (attachments is List) {
          print('Attachments count: ${attachments.length}');
          for (var i = 0; i < attachments.length; i++) {
            print('  Attachment $i: ${attachments[i]['name']}');
          }
        }
      } else {
        print('Has EMLS_JSON_EMAIL_MICROSOFT: NO');
      }
      print('============================================');

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
      {String search = '',
      int limit = 10,
      int offset = 0,
      String idUsuario = ''}) async {
    try {
      final response = await dio
          .post('/actividad/listar-actividad-by-id-tipo-gestion', data: {
        'SEARCH': search,
        'OFFSET': offset,
        'TOP': limit,
        'ID_USUARIO_RESPONSABLE': idUsuario
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
    String ruc = '',
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
        'ACTI_ID_OPORTUNIDAD': opportunityId,
        'RUC': ruc,
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

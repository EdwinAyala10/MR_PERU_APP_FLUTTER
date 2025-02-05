import '../../domain/datasources/indicators_datasource.dart';
import '../../domain/entities/indicator_response.dart';
import '../infrastructure.dart';
import 'package:dio/dio.dart';
import '../../../../config/config.dart';

class IndicatorsDatasourceImpl extends IndicatorsDatasource {
  late final Dio dio;
  final String accessToken;

  IndicatorsDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<IndicatorResponse> sendIndicators(Map<dynamic, dynamic> params) async {
    try {
      const String method = 'POST';
      const String url = '/indicators/report';

      final response = await dio.request(url,
          data: params, options: Options(method: method));

      final IndicatorResponse indicatorResponse =
          IndicatorResponseMapper.jsonToEntity(response.data);

      return indicatorResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw IndicatorNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

}

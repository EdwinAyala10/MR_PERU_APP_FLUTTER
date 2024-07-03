import 'package:dio/dio.dart';

import '../infrastructure.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

class RoutePlannerDatasourceImpl extends RoutePlannerDatasource {
  late final Dio dio;
  final String accessToken;

  RoutePlannerDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<List<CompanyLocalRoutePlanner>> getCompanyLocals({ int limit = 10, int offset = 0, String search = '' }) async {
    final response =
        await dio.post('/cliente/listar-clientes-local', data: {
          'SEARCH': search,
          'OFFSET': offset,
          'TOP': limit,
        });

    final List<CompanyLocalRoutePlanner> locales = [];

    for (final local in response.data['data'] ?? []) {
      locales.add(CompanyLocalRoutePlannerMapper.jsonToEntity(local));
    }

    return locales;
  }

}

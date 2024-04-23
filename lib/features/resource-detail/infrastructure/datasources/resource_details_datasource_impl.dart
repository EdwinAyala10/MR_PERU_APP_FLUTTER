import 'package:crm_app/features/resource-detail/domain/domain.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';

import '../mappers/resource_detail_mapper.dart';

class ResourceDetailsDatasourceImpl extends ResourceDetailsDatasource {
  late final Dio dio;
  final String accessToken;

  ResourceDetailsDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<List<ResourceDetail>> getResourceDetailsByGroup(String idGroup) async {
    final response = await dio.post(
        '/recurso-detalle/listar-recursos-detalle-by-grupo',
        data: {'RECD_GRUPO': idGroup});

    final List<ResourceDetail> resourceDetails = [];

    print('response getResourceDetailsByGroup :${response}');

    for (final resourceDetail in response.data['data'] ?? []) {
      resourceDetails.add(ResourceDetailMapper.jsonToEntity(resourceDetail));
    }

    return resourceDetails;
  }
}

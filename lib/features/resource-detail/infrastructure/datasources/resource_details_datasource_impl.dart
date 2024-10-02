import '../../domain/domain.dart';
import 'package:dio/dio.dart';
import '../../../../config/config.dart';

import '../mappers/resource_detail_mapper.dart';

class ResourceDetailsDatasourceImpl extends ResourceDetailsDatasource {
  late final Dio dio;
  final String accessToken;

  ResourceDetailsDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<List<ResourceDetail>> getResourceDetailsByGroup({ String idGroup = '', String idCodigo = '' }) async {
    
    Object dataArr = {
      'RECD_GRUPO': idGroup,
    };

    if (idCodigo!="") {
      dataArr = {
        'RECD_GRUPO': idGroup,
        'RECD_CODIGO': idCodigo
      };
    }
    
    final response = await dio.post(
        '/recurso-detalle/listar-recursos-detalle-by-grupo',
        data: dataArr);

    final List<ResourceDetail> resourceDetails = [];

    for (final resourceDetail in response.data['data'] ?? []) {
      resourceDetails.add(ResourceDetailMapper.jsonToEntity(resourceDetail));
    }

    return resourceDetails;
  }

  @override
  Future<List<ResourceDetail>> getResourceDetailsVisibleByGroup({ String idGroup = '', String idCodigo = '' }) async {
    
    Object dataArr = {
      'RECD_GRUPO': idGroup,
    };

    if (idCodigo!="") {
      dataArr = {
        'RECD_GRUPO': idGroup,
        'RECD_CODIGO': idCodigo
      };
    }
    
    final response = await dio.post(
        '/recurso-detalle/listar-recursos-detalle-visible-by-grupo',
        data: dataArr);

    final List<ResourceDetail> resourceDetails = [];

    for (final resourceDetail in response.data['data'] ?? []) {
      resourceDetails.add(ResourceDetailMapper.jsonToEntity(resourceDetail));
    }

    return resourceDetails;
  }
}

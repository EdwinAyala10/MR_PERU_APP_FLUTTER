import '../../domain/domain.dart';
import 'resource_detail_mapper.dart';

class RubroResponseMapper {
  static RubroResponse jsonToEntity(Map<dynamic, dynamic> json) {
    final response = RubroResponse(
      icon: json['icon'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      type: json['type'] ?? '',
    );

    if (response.status == true && json['data'] != null) {
      response.resourceDetail = ResourceDetailMapper.jsonToEntity(json['data']);
    }

    return response;
  }
}

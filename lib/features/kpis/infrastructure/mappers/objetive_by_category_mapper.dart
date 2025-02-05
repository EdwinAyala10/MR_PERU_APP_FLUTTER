import 'package:crm_app/features/kpis/domain/entities/objetive_by_category.dart';

class ObjetiveByCategoryMapper {
  static jsonToEntity(Map<String, dynamic> json) =>
      ObjetiveByCategory.fromJson(json);
}

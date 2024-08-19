import 'package:crm_app/features/kpis/domain/entities/objetive_by_category.dart';

class ObjetiveByCategoryResponse {
  String type;
  String icon;
  bool status;
  String message;
  List<ObjetiveByCategory>? kpi;

  ObjetiveByCategoryResponse({
    required this.type,
    required this.icon,
    required this.status,
    required this.message,
    this.kpi,
  });
}

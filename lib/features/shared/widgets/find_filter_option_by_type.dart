import 'package:crm_app/features/route-planner/domain/domain.dart';

String? findFilterOptionByType(List<FilterOption> filters, String type, String param, String empty) {
  try {
    if (filters.length>0) {
      if (param == 'id') {
        return filters.firstWhere((filter) => filter.type == type).id;
      } else if (param == 'name') {
        return filters.firstWhere((filter) => filter.type == type).name;
      } else if (param == 'type') {
        return filters.firstWhere((filter) => filter.type == type).type;
      } else {
        return empty;
      }
    } else {
      return empty;
    }
   
  } catch (e) {
    return empty;
  }
}
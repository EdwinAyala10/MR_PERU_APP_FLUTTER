import 'package:crm_app/features/kpis/domain/domain.dart';

class KpiResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => KpiResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

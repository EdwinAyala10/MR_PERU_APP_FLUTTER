import 'package:crm_app/features/companies/domain/entities/check_in_by_ruc_local_response.dart';

class CheckInByRucLocalResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CheckInByRucLocalResponse(
    icon: json['icon'] ?? '',
    message: json['message'] ?? '',
    status: json['status'] ?? '',
    type: json['type'] ?? '',
  );

}

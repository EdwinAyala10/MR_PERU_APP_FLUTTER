import 'package:crm_app/features/opportunities/domain/domain.dart';

class OpportunityResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => OpportunityResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}
import '../../domain/entities/indicator_response.dart';

class IndicatorResponseMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => IndicatorResponse(
    icon: json['icon'],
    message: json['message'],
    status: json['status'],
    type: json['type'],
  );

}

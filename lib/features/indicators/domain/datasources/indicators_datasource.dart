import '../entities/indicator_response.dart';

abstract class IndicatorsDatasource {

  Future<IndicatorResponse> sendIndicators( Map<dynamic,dynamic> params );

}


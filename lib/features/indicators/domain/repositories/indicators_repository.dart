import '../entities/indicator_response.dart';

abstract class IndicatorsRepository {

  Future<IndicatorResponse> sendIndicators( Map<dynamic,dynamic> params );
}


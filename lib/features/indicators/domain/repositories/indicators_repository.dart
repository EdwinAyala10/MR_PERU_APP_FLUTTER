import 'package:crm_app/features/indicators/domain/entities/indicator_response.dart';

abstract class IndicatorsRepository {

  Future<IndicatorResponse> sendIndicators( Map<dynamic,dynamic> params );
}

